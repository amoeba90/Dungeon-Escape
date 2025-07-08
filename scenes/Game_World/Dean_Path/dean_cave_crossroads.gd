# dean_cave_crossroads.gd
extends Node2D

var web_burned = false
var pending_action = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_cave_crossroads" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_cave_crossroads"]
		
		if "web_burned" in room_state and room_state["web_burned"]:
			web_burned = true
			# Set visual state - show final burned web state
			$Background/Background_Original.visible = false
			$Background/Background_WebBurnEnd.visible = true
			
			# Unlock the middle cave door
			var cave_boss_area = $InteractiveAreas/CaveBoss_Area
			cave_boss_area.next_scene_path = "res://scenes/Game_World/Dean_Path/dean_cave_boss.tscn"
			cave_boss_area.play_sound = true # Enable walking sound for saved game
			print("Loaded saved state: Web already burned, middle path unlocked")
	
	# Connect dialogue signal
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func handle_transition(type: String) -> void:
	# Don't allow interactions during dialogue
	if DialogueManager.is_dialogue_active():
		return
	
	match type:
		"cave_left":
			# Left cave is always accessible - handled by next_room.gd automatically
			pass
			
		"cave_right": 
			# Right cave is always accessible - handled by next_room.gd automatically
			pass
			
		"cave_middle":
			# Middle cave - check if web is burned
			var cave_boss_area = $InteractiveAreas/CaveBoss_Area
			
			if not web_burned:
				# Web is blocking the path - check for torch
				if InventoryUtils.has_item("torch"):
					print("Using torch to burn cobwebs")
					
					# Start the web burning sequence
					burn_web_sequence()
				else:
					# No torch - show blocked dialogue
					DialogueManager.start_dialogue([
						{"speaker": GlobalData.get_player_name(), "text": "The path is blocked by thick cobwebs."},
						{"speaker": GlobalData.get_player_name(), "text": "I need something to burn through them."}
					])
			# If web is already burned, the door will work automatically via next_room.gd

func burn_web_sequence():
	# Start burning animation sequence
	$Background/Background_Original.visible = false
	$Background/Background_WebBurnStart.visible = true
	
	# Play burning sound using AudioManager
	AudioManager.play_sfx("res://assets/Audio/SFX/cobweb-burn.mp3")
	
	# Stage 1: Web starts burning
	await get_tree().create_timer(1.0).timeout
	$Background/Background_WebBurnStart.visible = false
	$Background/Background_WebBurnMiddle.visible = true
	
	# Stage 2: Web almost gone
	await get_tree().create_timer(1.0).timeout
	$Background/Background_WebBurnMiddle.visible = false
	$Background/Background_WebBurnEnd.visible = true
	
	# Mark web as burned
	web_burned = true
	
	# Unlock the middle cave door
	var cave_boss_area = $InteractiveAreas/CaveBoss_Area
	cave_boss_area.next_scene_path = "res://scenes/Game_World/Dean_Path/dean_cave_boss.tscn"
	cave_boss_area.play_sound = true # Enable walking sound
	
	# Save the state
	save_room_state()
	
	# Show completion dialogue
	pending_action = "web_burned"
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "The cobwebs are burned away!"},
		{"speaker": GlobalData.get_player_name(), "text": "Now I can access this path."}
	])

func _on_dialogue_ended():
	match pending_action:
		"web_burned":
			pending_action = ""
			# Web burning sequence is complete

# Save room state
func save_room_state():
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	var room_state = {
		"web_burned": web_burned
	}
	
	SaveSystem.save_data["room_states"]["dean_cave_crossroads"] = room_state
	SaveSystem.save_game()
	print("Saved room state: Web burned = ", web_burned)
