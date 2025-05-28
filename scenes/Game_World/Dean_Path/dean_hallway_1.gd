# dean_hallway_1.gd
extends Node2D

var first_visit_sound_played = false
var first_visit_dialogue_shown = false
var first_visit_complete = false
var pending_action = "" # For dialogue callback tracking

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Assign game_utils and fade_overlay to the doors
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# Connect to dialogue ended signal for callbacks
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Check saved state to see if this is first visit
	if "room_states" in SaveSystem.save_data and "dean_hallway_1" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_hallway_1"]
		
		if "first_visit_sound_played" in room_state:
			first_visit_sound_played = room_state["first_visit_sound_played"]
			
		if "first_visit_dialogue_shown" in room_state:
			first_visit_dialogue_shown = room_state["first_visit_dialogue_shown"]
		
		# If both sound and dialogue have been shown, mark as complete
		if first_visit_sound_played and first_visit_dialogue_shown:
			first_visit_complete = true
	
	# Disable doors initially if this is the first visit
	if not first_visit_complete:
		disable_door_interactions()
	
	# If this is the first visit, handle special entry events
	if not first_visit_sound_played:
		# Use call_deferred to ensure the scene is fully loaded first
		call_deferred("handle_first_visit")
	else:
		# Not first visit, enable doors immediately
		first_visit_complete = true

# Function to disable door interactions
func disable_door_interactions():
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# Disable both monitoring and input processing
	left_door.monitoring = false
	left_door.input_pickable = false
	left_door.set_process_input(false)
	
	right_door.monitoring = false
	right_door.input_pickable = false
	right_door.set_process_input(false)

# Function to enable door interactions
func enable_door_interactions():
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# Enable both monitoring and input processing
	left_door.monitoring = true
	left_door.input_pickable = true
	left_door.set_process_input(true)
	
	right_door.monitoring = true
	right_door.input_pickable = true
	right_door.set_process_input(true)

# Function to handle first visit effects
func handle_first_visit():
	# Wait a moment for the scene to settle
	await get_tree().create_timer(0.5).timeout
	
	# Play special "first entry" sound
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/Audio/SFX/metal-clang.mp3")
	add_child(audio_player)
	audio_player.play()
	
	# Mark that we've played the sound
	first_visit_sound_played = true
	save_room_state()
	
	# Wait for sound to finish before showing dialogue
	await audio_player.finished
	audio_player.queue_free()
	
	# Show first visit dialogue if not shown yet
	if not first_visit_dialogue_shown and not DialogueManager.is_dialogue_active():
		pending_action = "first_visit_dialogue"
		
		DialogueManager.start_dialogue([
			{"speaker": GlobalData.get_player_name(), "text": "What was that sound?"},
			{"speaker": GlobalData.get_player_name(), "text": "It came from behind me..."},
		])

# Handle dialogue completion callbacks
func _on_dialogue_ended():
	match pending_action:
		"first_visit_dialogue":
			# Mark first visit dialogue as shown
			first_visit_dialogue_shown = true
			first_visit_complete = true  # Mark the entire first visit as complete
			
			# Enable door interactions now that everything is done
			enable_door_interactions()
			
			save_room_state()
			pending_action = ""

# Function to save room state
func save_room_state():
	# Make sure room_states exists
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	# Create or update this room's state
	var room_state = {
		"first_visit_sound_played": first_visit_sound_played,
		"first_visit_dialogue_shown": first_visit_dialogue_shown
	}
	
	# Save to the SaveSystem
	SaveSystem.save_data["room_states"]["dean_hallway_1"] = room_state
	SaveSystem.save_game()

# toggle background visibiility based on the door clicked
func handle_transition(type: String) -> void:
	# Don't allow door transitions during first visit sequence OR during dialogue
	if not first_visit_complete or DialogueManager.is_dialogue_active():
		return
		
	match type:
		"left_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_LeftDoorOpen.visible = true # show left door open visual
		"right_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_RightDoorOpen.visible = true # show right door open visual
