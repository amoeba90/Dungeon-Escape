# dean_rock_room.gd
extends Node2D

var lever_pulled = false
var rocks_falling = false
var rocks_on_floor = false
var dialogue_shown = false # New variable to track if we've shown the dialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_rock_room" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_rock_room"]
		
		if "lever_pulled" in room_state and room_state["lever_pulled"]:
			lever_pulled = true
		
		if "rocks_on_floor" in room_state and room_state["rocks_on_floor"]:
			rocks_on_floor = true
			$Background/Background_Original.visible = false
			$Background/Background_RockFallEnd.visible = true
			
		if "dialogue_shown" in room_state and room_state["dialogue_shown"]:
			dialogue_shown = true
	
	# assign interactive areas
	var lever = $InteractiveAreas/Lever_Area
	var down_arrow = $InteractiveAreas/DownArrow_Area
	
	# Check if we need to show dialogue when entering the room with rocks already fallen
	if rocks_on_floor and not dialogue_shown:
		call_deferred("show_blocked_path_dialogue")

# toggle background visibiility based on the door clicked
func handle_transition(type: String) -> void:
	match type:
		"pull_lever":
			if not lever_pulled:
				lever_pulled = true
				
				$Background/Background_Original.visible = false
				$Background/Background_LeverPull.visible = true
				# wait half a second
				await get_tree().create_timer(1.0).timeout
				rocks_falling = true
				
				$Background/Background_LeverPull.visible = false
				$Background/Background_RockFallStart.visible = true
				# wait half a second
				await get_tree().create_timer(0.5).timeout
				rocks_on_floor = true
				
				$Background/Background_RockFallStart.visible = false
				$Background/Background_RockFallEnd.visible = true
				
				# Save room state
				var room_state = {
					"lever_pulled": true,
					"rocks_on_floor": true,
					"dialogue_shown": false # We haven't shown dialogue yet
				}
				SaveSystem.save_data["room_states"]["dean_rock_room"] = room_state
				SaveSystem.save_game()
				
				# Wait a second before playing dialogue
				await get_tree().create_timer(1).timeout
				
				# Show dialogue about blocked path
				show_blocked_path_dialogue()

# Function to show dialogue about blocked path
func show_blocked_path_dialogue():
	if not DialogueManager.is_dialogue_active():
		DialogueManager.start_dialogue([
			{"speaker": GlobalData.get_player_name(),"text": "The path is blocked by rocks."},
			{"speaker": GlobalData.get_player_name(),"text": "Looks like I'm going to have to turn around."}
		])
		
		# Mark dialogue as shown in room state
		if "room_states" in SaveSystem.save_data and "dean_rock_room" in SaveSystem.save_data["room_states"]:
			SaveSystem.save_data["room_states"]["dean_rock_room"]["dialogue_shown"] = true
			SaveSystem.save_game()
			dialogue_shown = true
