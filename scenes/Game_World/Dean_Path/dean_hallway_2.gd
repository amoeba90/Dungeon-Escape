# dean_hallway_2.gd
extends Node2D

# Path to the room the double door leads to
const LOCKED_ROOM_PATH = "res://scenes/Game_World/Dean_Path/dean_hallway_3.tscn"
# Function to set up door logic
func _ready() -> void:
	# Load saved state first
	var door_unlocked = false
	if "room_states" in SaveSystem.save_data and "dean_hallway_2" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_hallway_2"]
		
		if "double_door_unlocked" in room_state and room_state["double_door_unlocked"]:
			door_unlocked = true
			print("Loaded saved state: Double door is unlocked")
	
	# Get double door reference
	var double_door = $InteractiveAreas/DoubleDoor_Area
	if double_door:
		if door_unlocked:
			# Door is already unlocked, set the path
			double_door.next_scene_path = LOCKED_ROOM_PATH
			print("Door already unlocked, path set to: " + LOCKED_ROOM_PATH)
		else:
			# Door is locked, clear the path (even if it's set in the inspector)
			double_door.next_scene_path = ""
			print("Door is locked, path cleared")

# Modified handle_transition function
func handle_transition(type: String) -> void:
	match type:
		"left_door":
			$Background/Background_Original.visible = false
			$Background/Background_LeftDoorOpen.visible = true
		"right_door":
			$Background/Background_Original.visible = false
			$Background/Background_RightDoorOpen.visible = true
		"double_door":
			# Get the double door reference
			var double_door = $InteractiveAreas/DoubleDoor_Area
			if not double_door:
				return
				
			# Check if the door is locked (no path)
			if double_door.next_scene_path == "":
				# Door is locked, check for key
				if InventoryUtils.has_item("key"):
					print("Using key to unlock door")
					
					# Player has key, unlock door
					InventoryUtils.remove_item("key")
					
					# Show dialogue
					DialogueManager.start_dialogue([{"text": "The key fits perfectly. The door is now unlocked."}])
					
					# Mark door as unlocked in saved state
					save_door_state(true)
					
					# Cancel this interaction so player needs to click again
					await get_tree().create_timer(0.1).timeout
					double_door.is_clicked = false
					
					# Set the path for next click
					double_door.next_scene_path = LOCKED_ROOM_PATH
					print("Door unlocked, path set to: " + LOCKED_ROOM_PATH)
				else:
					# No key, just show dialogue without changing background
					DialogueManager.start_dialogue([{"text": "The door is locked. I need a key to open it."}])
					
					# Cancel this interaction
					await get_tree().create_timer(0.1).timeout
					double_door.is_clicked = false
			else:
				# Door is already unlocked, show open animation normally
				$Background/Background_Original.visible = false
				$Background/Background_DoubleDoorOpen.visible = true
				
				# Scene change will happen automatically through your door system

# Save door state
func save_door_state(unlocked: bool):
	# Make sure room_states exists in save data
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	# Create or update this room's state
	var room_state = {
		"double_door_unlocked": unlocked
	}
	
	# Save to the save system
	SaveSystem.save_data["room_states"]["dean_hallway_2"] = room_state
	SaveSystem.save_game()
	print("Saved room state: Double door unlocked = ", unlocked)
