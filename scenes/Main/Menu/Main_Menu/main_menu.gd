# main_menu.gd
extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# check if save file exists
	if FileAccess.file_exists(SaveSystem.save_file_path):
		$VBoxContainer/Continue_Button.visible = true # Show the Load Game button
	else:
		$VBoxContainer/Continue_Button.visible = false # Hide the Load Game button

func _on_New_Game_Button_pressed():
	SaveSystem.save_data = {
		"current_room": "res://scenes/Game_World/starting_room.tscn", 
		"inventory": [],
		"room_states": {}
	}
	SaveSystem.save_game() # save initial game state
	# start game by transitioning to first room
	GameUtils.change_scene(SaveSystem.save_data["current_room"])

func _on_Continue_Button_pressed():
	SaveSystem.load_game()
	#after loading, transition to the saved room
	GameUtils.change_scene(SaveSystem.save_data["current_room"])

func _on_Settings_Button_pressed():
	var settings_scene = load("res://scenes/Systems/settings.tscn").instantiate()
	get_tree().root.add_child(settings_scene)
	# set the previous scene to return to
	settings_scene.previous_scene = "res://scenes/Main/Menu/Main_Menu/main_menu.tscn"
	self.visible = false

func _on_Quit_Button_pressed():
	get_tree().quit()
