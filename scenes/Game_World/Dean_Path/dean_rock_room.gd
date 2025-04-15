# dean_rock_room.gd
extends Node2D

var lever_pulled = false
var rocks_falling = false
var rocks_on_floor = false

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
	
	# assign interactive areas
	var lever = $InteractiveAreas/Lever_Area
	var down_arrow = $InteractiveAreas/DownArrow_Area

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
				await get_tree().create_timer(1.0).timeout
				rocks_on_floor = true
				
				$Background/Background_RockFallStart.visible = false
				$Background/Background_RockFallEnd.visible = true
				
				var room_state = {
					"lever_pulled": true,
					"rocks_on_floor": true
				}
				SaveSystem.save_data["room_states"]["dean_rock_room"] = room_state
				SaveSystem.save_game
