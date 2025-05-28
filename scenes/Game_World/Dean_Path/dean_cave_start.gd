# dean_cave_start.gd
extends Node2D

var enemy_defeated = false
var cave_door_unlocked = false
var crystal_taken = false
var pending_action = ""

# Path to the room the cave door leads to
const LOCKED_ROOM_PATH = "res://scenes/Game_World/Dean_Path/dean_cave_crossroads.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_cave_start" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_cave_start"]
		
		if "enemy_defeated" in room_state and room_state["enemy_defeated"]:
			enemy_defeated = true
			# Set visual state based on crystal status
			if "crystal_taken" in room_state and room_state["crystal_taken"]:
				crystal_taken = true
				$Background/Background_ZombieDead.visible = true
			else:
				$Background/Background_ZombieDeadCrystal.visible = true
			# Hide the original background
			$Background/Background_ZombieStart.visible = false
		
		if "cave_door_unlocked" in room_state and room_state["cave_door_unlocked"]:
			cave_door_unlocked = true
			print("Loaded saved state: Cave door is unlocked")
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# If zombie hasn't been defeated yet, start the fight automatically
	if not enemy_defeated:
		call_deferred("fight_sequence")

func fight_sequence():
	# Wait a moment for the scene to fully load
	await get_tree().create_timer(1.0).timeout
	DialogueManager.start_dialogue([
			{"speaker": GlobalData.get_player_name(), "text": "A zombie?"},
			{"speaker": GlobalData.get_player_name(), "text": "Oh no, I think it saw me!"}
		])
	await DialogueManager.dialogue_ended
	
	# Stage 1: Zombie sees you
	await get_tree().create_timer(1.0).timeout
	$Background/Background_ZombieStart.visible = false
	$Background/Background_ZombieMiddle.visible = true
	
	# Stage 2: Zombie approaches
	await get_tree().create_timer(1.0).timeout
	$Background/Background_ZombieMiddle.visible = false
	$Background/Background_ZombieStop.visible = true
	
	# Check if player has sword
	if InventoryUtils.has_item("sword"):
		# Player has sword - victory sequence
		await get_tree().create_timer(1.0).timeout
		$Background/Background_ZombieStop.visible = false
		$Background/Background_ZombieHit.visible = true
		
		# Play sword hit sound
		var audio_player = AudioStreamPlayer.new()
		var sword_sound_path = "res://assets/Audio/SFX/sword-sound-2-36274.mp3"
		if ResourceLoader.exists(sword_sound_path):
			audio_player.stream = load(sword_sound_path)
			add_child(audio_player)
			audio_player.play()
			audio_player.finished.connect(func(): audio_player.queue_free())
		else:
			print("Warning: Sword hit sound not found at " + sword_sound_path)
		
		await get_tree().create_timer(1.0).timeout
		$Background/Background_ZombieHit.visible = false
		$Background/Background_ZombieDeadCrystal.visible = true
		
		enemy_defeated = true
		
		# Unlock the cave door now that zombie is defeated
		var cave_door = $InteractiveAreas/CaveDoor_Area
		cave_door.next_scene_path = LOCKED_ROOM_PATH
		
		save_room_state()
		
		# Show victory dialogue
		DialogueManager.start_dialogue([
			{"speaker": GlobalData.get_player_name(), "text": "I defeated the zombie! There's something shiny in its remains."},
			{"speaker": GlobalData.get_player_name(), "text": "The path ahead is now clear."}
		])
	else:
		# Player doesn't have sword - death sequence
		await get_tree().create_timer(1.0).timeout
		show_death_menu()

func show_death_menu():
	# Load and show death menu scene
	var death_menu_scene = preload("res://scenes/Main/Menu/Death_Menu/death_menu.tscn")
	var death_menu = death_menu_scene.instantiate()
	get_tree().root.add_child(death_menu)
	
	# Pause the game
	get_tree().paused = true

func handle_transition(type: String) -> void:
	if DialogueManager.is_dialogue_active():
		return
	
	match type:
		"crystal":
			if enemy_defeated and not crystal_taken:
				# Zombie is dead but crystal not taken - pick up crystal
				var crystal_item = {
					"id": "crystal",
					"name": "Crystal",
					"description": "A mysterious glowing crystal.",
					"icon_path": "res://assets/Sprites/Inventory/crystal_shard.PNG",
					"use_sound_path": "res://assets/Audio/SFX/crystal.mp3"
				}
				
				# Add to inventory
				SaveSystem.save_data["inventory"].append(crystal_item)
				SaveSystem.save_game()
				
				# Update visuals
				crystal_taken = true
				pending_action = "crystal_taken"
				$Background/Background_ZombieDeadCrystal.visible = false
				$Background/Background_ZombieDead.visible = true
				
				# Show dialogue
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(), "text": "A mysterious crystal! This might be useful later."}
				])
				
				save_room_state()
			else:
				# Zombie is dead and crystal already taken - just show dead zombie
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(), "text": "The zombie remains motionless."}
				])
		"cave_door":
			pass

func _on_dialogue_ended():
	match pending_action:
		"crystal_done":
			pending_action = ""
			# Refresh inventory display if open
			var main = get_node("/root/Main")
			if main and main.inventory_instance:
				main.inventory_instance.load_inventory()

func save_room_state():
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	var room_state = {
		"enemy_defeated": enemy_defeated,
		"cave_door_unlocked": cave_door_unlocked,
		"crystal_taken": crystal_taken
	}
	
	SaveSystem.save_data["room_states"]["dean_cave_start"] = room_state
	SaveSystem.save_game()
