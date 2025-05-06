# dean_entrance_blocked
extends Node2D

var dialogue_shown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the arrow's Area2D
	var down_arrow = $InteractiveAreas/DownArrow_Area
	
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_entrance_blocked" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_entrance_blocked"]
		
		if "dialogue_shown" in room_state and room_state["dialogue_shown"]:
			dialogue_shown = true
	
	# Show dialogue after a short delay if it hasn't been shown yet
	if not dialogue_shown:
		# Wait for any scene transition to complete plus 1 second
		call_deferred("show_entrance_blocked_dialogue")

# Function to show dialogue about blocked entrance
func show_entrance_blocked_dialogue():
	# Wait a second before showing dialogue
	await get_tree().create_timer(1.0).timeout
	
	if not DialogueManager.is_dialogue_active():
		DialogueManager.start_dialogue([
			{"text": "Bars block the doorway as I pass through, no turning back now."}
		])
		
		# Mark dialogue as shown in room state
		if not "room_states" in SaveSystem.save_data:
			SaveSystem.save_data["room_states"] = {}
			
		var room_state = {
			"dialogue_shown": true
		}
		SaveSystem.save_data["room_states"]["dean_entrance_blocked"] = room_state
		SaveSystem.save_game()
		dialogue_shown = true
