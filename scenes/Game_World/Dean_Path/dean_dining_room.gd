# dean_dining_room.gd
extends Node2D

var drawer_open = false
var key_taken = false
var pending_action = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_dining_room" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_dining_room"]
		
		if "key_taken" in room_state and room_state["key_taken"]:
			key_taken = true
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# assign interactive areas
	var cabinet = $InteractiveAreas/Cabinet_Area
	var drawer = $InteractiveAreas/Drawer_Area
	var down_arrow = $InteractiveAreas/DownArrow_Area

func update_visuals():
	$Background/Background_Original.visible = false
	$Background/Background_DrawerKey.visible = false
	$Background/Background_DrawerEmpty.visible = false
	$Background/Background_CabinetEmpty.visible = false
	
	if drawer_open:
		if key_taken:
			$Background/Background_DrawerEmpty.visible = true
		else:
			$Background/Background_DrawerKey.visible = true
	else:
		$Background/Background_Original.visible = true

# toggle background visibiility based on the door clicked
func handle_transition(type: String) -> void:
	var drawer = $InteractiveAreas/Drawer_Area
	if DialogueManager.is_dialogue_active():
		return
	
	match type:
		"cabinet":
			$Background/Background_Original.visible = false
			$Background/Background_CabinetEmpty.visible = true
			# play dialogue
			DialogueManager.start_dialogue([
				{"speaker": GlobalData.get_player_name(), "text": "Nothing is in here."}
			])
			pending_action = "cabinet_done"
		"drawer":
			if not drawer_open:
				drawer_open = true
				drawer.play_sound = true
				update_visuals()
				
			elif drawer_open and not key_taken:
				key_taken = true
				drawer.play_sound = false
				
				# Create a proper item object
				var key_item = {
					"id": "key",
					"name": "Key",
					"description": "A key that might open a door somewhere.",
					"icon_path": "res://assets/Sprites/Inventory/key.PNG",
					"use_sound_path": "res://assets/Audio/SFX/key.mp3"
				}
				
				# Replace any existing key string with the new key object
				var inventory = SaveSystem.save_data["inventory"]
				var item_index = inventory.find("key")
				if item_index != -1:
					# Replace the string key with the new key item
					inventory[item_index] = key_item
					print("Replaced string 'key' with key_item dictionary")
				else:
					# Add the new key item
					inventory.append(key_item)
					print("Added new key_item dictionary to inventory")
				
				# Save room state
				var room_state = {
					"key_taken": true
				}
				SaveSystem.save_data["room_states"]["dean_dining_room"] = room_state
				SaveSystem.save_game()
				
				print("Inventory contents after update: ", SaveSystem.save_data["inventory"])
				
				# Refresh inventory display if it exists
				var main = get_node("/root/Main")
				if main and main.inventory_instance:
					main.inventory_instance.load_inventory()
				
				# dialogue
				DialogueManager.start_dialogue([
					{"Speaker": GlobalData.get_player_name(), "text": "A key! I wonder what this opens?"}
				])
				pending_action = "close_drawer"
				
			elif drawer_open and key_taken:
				drawer_open = false
				update_visuals()
				drawer.play_sound = true

func _on_dialogue_ended():
	match pending_action:
		"cabinet_done":
			update_visuals()
			pending_action = ""
		"close_drawer":
			drawer_open = false
			update_visuals()
			pending_action = ""
