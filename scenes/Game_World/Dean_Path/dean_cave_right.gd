# dean_cave_right.gd
extends Node2D

var enemy_defeated = false
var torch_taken = false
var pending_action = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_cave_right" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_cave_right"]
		
		if "enemy_defeated" in room_state and room_state["enemy_defeated"]:
			enemy_defeated = true
			# Set visual state based on torch status
			if "torch_taken" in room_state and room_state["torch_taken"]:
				torch_taken = true
				$Background/Background_TorchTaken.visible = true
			else:
				$Background/Background_GhostDead.visible = true
			# Hide the original background
			$Background/Background_Original.visible = false
			print("Loaded saved state: Ghosts already defeated")
		if "torch_taken" in room_state and room_state["torch_taken"]:
			torch_taken = true
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# If ghosts haven't been defeated yet, start the encounter automatically
	if not enemy_defeated:
		call_deferred("fight_sequence")

func fight_sequence():
	# Wait a moment for the scene to fully load
	await get_tree().create_timer(1.0).timeout
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "Ghosts!"},
		{"speaker": GlobalData.get_player_name(), "text": "Hmmm, they seem friendly for now."}
	])

func handle_transition(type: String) -> void:
	if DialogueManager.is_dialogue_active():
		return
	
	match type:
		"ghost":
			if not enemy_defeated:
				# Ghosts are alive - check if player wants to attack
				if InventoryUtils.has_item("crystal"):
					# Player has crystal - attack ghosts
					attack_ghosts()
				else:
					# No crystal - cautious dialogue
					DialogueManager.start_dialogue([
						{"speaker": GlobalData.get_player_name(), "text": "I don't think I should bother them, who knows what they'll do."}
					])
			else:
				# Ghosts already dead - no interaction needed
				pass
		
		"torch":
			if not enemy_defeated:
				# Ghosts are blocking the torch
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(), "text": "I can't reach the torch, they're blocking the way."}
				])
			elif enemy_defeated and not torch_taken:
				# Ghosts are dead, can take torch
				take_torch()
			else:
				# Torch already taken
				pass

func attack_ghosts():
	# Ghost attack sequence
	$Background/Background_Original.visible = false
	$Background/Background_GhostHit.visible = true
	
	# Play crystal use sound (built-in item sound)
	var crystal_item = InventoryUtils.get_item("crystal")
	if crystal_item.has("use_sound_path"):
		AudioManager.play_sfx(crystal_item.use_sound_path)
	
	await get_tree().create_timer(1.0).timeout
	$Background/Background_GhostHit.visible = false
	$Background/Background_GhostDead.visible = true
	
	# Play ghost death sound
	AudioManager.play_sfx("res://assets/Audio/SFX/ghost-death.wav")
	
	enemy_defeated = true
	save_room_state()
	
	# Show apology dialogue
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "Sorry ghosties."}
	])

func take_torch():
	# Create torch item
	var torch_item = {
		"id": "torch",
		"name": "Torch",
		"description": "A burning torch that could be useful for lighting things.",
		"icon_path": "res://assets/Sprites/Inventory/torch_dean.png",
		"use_sound_path": ""
	}
	
	# Add to inventory
	SaveSystem.save_data["inventory"].append(torch_item)
	SaveSystem.save_game()
	
	# Update visuals
	torch_taken = true
	pending_action = "torch_taken"
	$Background/Background_GhostDead.visible = false
	$Background/Background_TorchTaken.visible = true
	
	# Show dialogue
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "A torch! I wonder what I can use this for."}
	])
	
	save_room_state()

func _on_dialogue_ended():
	match pending_action:
		"torch_taken":
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
		"torch_taken": torch_taken
	}
	
	SaveSystem.save_data["room_states"]["dean_cave_right"] = room_state
	SaveSystem.save_game()
