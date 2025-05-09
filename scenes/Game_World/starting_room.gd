# starting_room.gd
extends Node2D

var dialogue_complete = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# assign game_utils and fade_overlay to the doors
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# Disable door interaction initially
	disable_door_interaction()
	
	# Connect to dialogue ended signal
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Show intro dialogue after a short delay
	call_deferred("show_intro_dialogue")

# Function to disable door interaction
func disable_door_interaction():
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# Disable input on doors
	left_door.set_process_input(false)
	right_door.set_process_input(false)
	
	# Set monitoring to false to prevent detection
	left_door.monitoring = false
	right_door.monitoring = false

# Function to enable door interaction
func enable_door_interaction():
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# Enable input on doors
	left_door.set_process_input(true)
	right_door.set_process_input(true)
	
	# Set monitoring to true to detect interaction
	left_door.monitoring = true
	right_door.monitoring = true

# Function to show intro dialogue
func show_intro_dialogue():
	if not DialogueManager.is_dialogue_active():
		DialogueManager.start_dialogue([
			{"speaker": GlobalData.get_player_name(), "text": "Ahh, I think I'm lost."},
			{"speaker": GlobalData.get_player_name(), "text": "I came here looking for ancient treasure, but now what?"},
			{"speaker": GlobalData.get_player_name(), "text": "I need to find a way out of here."},
			{"speaker": GlobalData.get_player_name(), "text": "There are two doors ahead. I should choose one and see where it leads."}
		])

# Handle dialogue completion
func _on_dialogue_ended():
	dialogue_complete = true
	enable_door_interaction()

# toggle background visibiility based on the door clicked
func handle_transition(type: String) -> void:
	# Don't allow interactions if dialogue isn't complete
	if not dialogue_complete:
		return
		
	match type:
		"left_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_LeftDoorOpen.visible = true # show left door open visual
		"right_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_RightDoorOpen.visible = true # show right door open visual
