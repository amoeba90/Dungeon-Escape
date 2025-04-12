# main_menu.gd
extends Control

var debug_mode = true #change to false before release

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# only delete saves in debug mode
	if debug_mode:
		delete_save_file()
	# check if save file exists
	if FileAccess.file_exists(SaveSystem.save_file_path):
		$MarginContainer/VBoxContainer/ButtonContainer/Continue_Button.visible = true # Show the Load Game button
	else:
		$MarginContainer/VBoxContainer/ButtonContainer/Continue_Button.visible = false # Hide the Load Game button

func delete_save_file(): # while testing, i can use this to delete my previous safe file as id like
	if FileAccess.file_exists(SaveSystem.save_file_path):
		DirAccess.remove_absolute((SaveSystem.save_file_path))
		print("Save file deleted")

func _on_new_game_button_pressed():
	SaveSystem.save_data = {
		"current_room": "res://scenes/Game_World/starting_room.tscn", 
		"inventory": [],
		"room_states": {}
	}
	SaveSystem.save_game() # save initial game state
	# start game by transitioning to first room
	GameUtils.change_scene(SaveSystem.save_data["current_room"])

func _on_continue_button_pressed():
	var loaded_data = SaveSystem.load_game()
	if loaded_data != null and "current_room" in SaveSystem.save_data:
		GameUtils.change_scene(SaveSystem.save_data["current_room"])
	else:
		print("Failed to load save data")

func _on_settings_button_pressed():
	var settings_scene = load("res://scenes/Systems/settings.tscn").instantiate()
	get_tree().root.add_child(settings_scene)
	# set the previous scene to return to
	settings_scene.previous_scene = "res://scenes/Main/Menu/Main_Menu/main_menu.tscn"
	self.visible = false

func _on_quit_button_pressed():
	get_tree().quit()
