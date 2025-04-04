# main_menu.gd
extends Control

var save_system # assigned later in _ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save_file_path = "user://savegame.json" # path to save file
	var file = FileAccess.open(save_file_path, FileAccess.READ) # instantiate file access
	
	# assign save_system reference
	save_system = get_node("/root/Main/SaveSystem") # path to save system
	
	# check if save file exists
	if file: #FileAccess.open() returns null if file does not exist
		$Continue_Button.visible = true # Show the Load Game button
		file.close() 
	else:
		$Continue_Button.visible = false # Hide the Load Game button


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_New_Game_Button_pressed():
	save_system.save_data = {
		"current_room": "res://Scenes/starting_room.tscn", 
		"inventory": [],
		"room_states": {}
	}
	save_system.save_game() # save initial game state
	# start game by transitioning to first room
	get_tree().change_scene(save_system.save_data["current_room"])

func _on_Continue_Button_pressed():
	save_system.load_game()

func _on_Settings_Button_pressed():
	print("Settings button pressed") # temp debug line

func _on_Quit_Button_pressed():
	get_tree().quit()
