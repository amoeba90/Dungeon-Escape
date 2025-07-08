# dean_cave_left.gd
extends Node2D
var enemy_defeated = false
var pending_action = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_cave_left" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_cave_left"]
		
		if "enemy_defeated" in room_state and room_state["enemy_defeated"]:
			enemy_defeated = true
			# Set visual state to dead ghost
			$Background/Background_Original.visible = false
			$Background/Background_GhostDead.visible = true
			print("Loaded saved state: Ghost already defeated")
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# If ghost hasn't been defeated yet, start the fight automatically
	if not enemy_defeated:
		call_deferred("fight_sequence")

func fight_sequence():
	# Wait a moment for the scene to fully load
	await get_tree().create_timer(1.0).timeout
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "A ghost?"},
		{"speaker": GlobalData.get_player_name(), "text": "It's coming straight for me!"}
	])
	await DialogueManager.dialogue_ended
	
	# Stage 1: Ghost attacks
	await get_tree().create_timer(1.0).timeout
	$Background/Background_Original.visible = false
	$Background/Background_GhostAttack.visible = true
	
	# Check if player has crystal
	if InventoryUtils.has_item("crystal"):
		# Player has crystal - victory sequence
		await get_tree().create_timer(1.0).timeout
		$Background/Background_GhostAttack.visible = false
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
		
		# Show victory dialogue
		DialogueManager.start_dialogue([
			{"speaker": GlobalData.get_player_name(), "text": "The crystal repelled the ghost!"},
			{"speaker": GlobalData.get_player_name(), "text": "This is a dead end. I should head back."}
		])
	else:
		# Player doesn't have crystal - death sequence
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
		"ghost":
			if enemy_defeated:
				# Ghost is already dead - show dead ghost message
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(), "text": "The ghost has been banished."}
				])

func _on_dialogue_ended():
	match pending_action:
		_:
			pending_action = ""

func save_room_state():
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	var room_state = {
		"enemy_defeated": enemy_defeated
	}
	
	SaveSystem.save_data["room_states"]["dean_cave_left"] = room_state
	SaveSystem.save_game()
