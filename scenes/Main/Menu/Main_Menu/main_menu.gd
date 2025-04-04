# main_menu.gd
extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# check if save file exists
	if FileAccess.file_exists(SaveSystem.save_file_path):
		$Continue_Button.visible = true # Show the Load Game button
	else:
		$Continue_Button.visible = false # Hide the Load Game button

func _on_New_Game_Button_pressed():
	SaveSystem.save_data = {
		"current_room": "res://scenes/Game_World/starting_room.tscn", 
		"inventory": [],
		"room_states": {}
	}
	SaveSystem.save_game() # save initial game state
	# start game by transitioning to first room
	get_tree().change_scene(SaveSystem.save_data["current_room"])

func _on_Continue_Button_pressed():
	SaveSystem.load_game()

func _on_Settings_Button_pressed():
	print("Settings button pressed") # temp debug line

func _on_Quit_Button_pressed():
	get_tree().quit()
