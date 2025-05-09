# global_data.gd
extends Node

var player_name = "Adventurer"  # Default name

func set_player_name(new_name):
	player_name = new_name
	print("Player name set to: " + player_name)
	
	# Save the player name to the save data
	SaveSystem.save_data["player_name"] = player_name
	SaveSystem.save_game()

func get_player_name():
	# Try to load from save data first
	if "player_name" in SaveSystem.save_data:
		player_name = SaveSystem.save_data["player_name"]
	
	return player_name
