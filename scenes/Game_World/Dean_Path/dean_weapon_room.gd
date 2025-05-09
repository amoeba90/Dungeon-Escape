# dean_weapon_room.gd
extends Node2D

var sword_taken = false
var talked_to_npc = false
var pending_action = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_weapon_room" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_weapon_room"]
		
		if "sword_taken" in room_state and room_state["sword_taken"]:
			sword_taken = true
			$Background/Background_Original.visible = false
			$Background/Background_SwordTaken.visible = true
			
		if "talked_to_npc" in room_state and room_state["talked_to_npc"]:
			talked_to_npc = true
			
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func handle_transition(type: String) -> void:
	# Don't allow new interactions while dialogue is active
	if DialogueManager.is_dialogue_active():
		return
	
	match type:
		"npc":
			if not sword_taken:
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(),"text": "Who are you?"},
					{"speaker": "???", "text": "It doesn't matter who I am."},
					{"speaker": GlobalData.get_player_name(),"text": "Can I take this sword?"},
					{"speaker": "???", "text": "Take it. Nobody is coming back for it."}
				])
				talked_to_npc = true
			elif sword_taken && not talked_to_npc:
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(),"text": "Who are you?"},
					{"speaker": "???", "text": "It doesn't matter who I am."},
					{"speaker": GlobalData.get_player_name(),"text": "Is it okay if i took that sword?"},
					{"speaker": "???", "text": "It doesn't matter. Nobody is coming back for it anyway."}
				])
				talked_to_npc = true
			elif sword_taken && talked_to_npc:
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(),"text": "Is it okay if i took that sword?"},
					{"speaker": "???", "text": "You've already taken it. Just don't rely on it."},
					{"speaker": GlobalData.get_player_name(),"text": "What do you mean?"},
					{"speaker": "???", "text": "Weapons won't save you here."}
				])
		"sword":
			if !sword_taken:
				pending_action = "take_sword"
				
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(),"text": "A sword! This could help me defeat enemies."}
				])

# Handle dialogue completion
func _on_dialogue_ended():
	match pending_action:
		"take_sword":
			# Reset pending action
			pending_action = ""
			
			# Create a proper item object
			var sword_item = {
				"id": "sword",
				"name": "Sword",
				"description": "The sword to defeat the zombie.",
				"icon_path": "res://assets/Sprites/Inventory/sword.PNG"
			}
			
			# Replace any existing sword string with the new sword object
			var inventory = SaveSystem.save_data["inventory"]
			var item_index = inventory.find("sword")
			if item_index != -1:
				# Replace the string sword with the new sword item
				inventory[item_index] = sword_item
				print("Replaced string 'sword' with sword_item dictionary")
			else:
				# Add the new sword item
				inventory.append(sword_item)
				print("Added new sword_item dictionary to inventory")
			
			sword_taken = true
			
			save_room_state()
			
			print("Inventory contents after update: ", SaveSystem.save_data["inventory"])
			
			# Refresh inventory display if it exists
			var main = get_node("/root/Main")
			if main and main.inventory_instance:
				main.inventory_instance.load_inventory()
			
			# Update Background
			$Background/Background_Original.visible = false
			$Background/Background_SwordTaken.visible = true
			
			# Update sword_taken state
			sword_taken = true

# Helper function to save the room state
func save_room_state():
	# Make sure room_states exists
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	# Save both variables in the room state
	var room_state = {
		"sword_taken": sword_taken,
		"talked_to_npc": talked_to_npc
	}
	SaveSystem.save_data["room_states"]["dean_weapon_room"] = room_state
	SaveSystem.save_game()
