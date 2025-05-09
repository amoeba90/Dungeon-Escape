# main_menu.gd
extends Control

var debug_mode = true #change to false before release
var name_popup_scene = preload("res://scenes/Systems/player_name_customization.tscn")

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
	AudioManager.play_music("res://assets/Audio/Music/title.mp3")

func delete_save_file(): # while testing, i can use this to delete my previous safe file as id like
	if FileAccess.file_exists(SaveSystem.save_file_path):
		DirAccess.remove_absolute((SaveSystem.save_file_path))
		print("Save file deleted")

func _on_new_game_button_pressed():
	# First check if the scene exists
	var popup_path = "res://scenes/Systems/player_name_customization.tscn"
	if ResourceLoader.exists(popup_path):
		print("Name popup scene found at: " + popup_path)
		var name_popup_scene = load(popup_path)
		var name_popup = name_popup_scene.instantiate()
		
		# Add to the scene tree
		get_tree().root.add_child(name_popup)
		print("Name popup added to scene tree")
		
		# Connect signal
		name_popup.name_confirmed.connect(_on_name_confirmed)
		print("Signal connected")
		
		# Hide main menu
		self.visible = false
	else:
		print("ERROR: Name popup scene not found at path: " + popup_path)
		# Fall back to default name
		start_new_game("Player")

func _on_name_confirmed(player_name):
	print("Name confirmed: " + player_name)
	start_new_game(player_name)

func start_new_game(player_name):
	# Set player name in GlobalData
	GlobalData.set_player_name(player_name)
	
	# Initialize save data
	SaveSystem.save_data = {
		"current_room": "res://scenes/Game_World/starting_room.tscn", 
		"inventory": [],
		"room_states": {},
		"player_name": player_name
	}
	
	# Save initial game state
	SaveSystem.save_game()
	print("Starting new game with player name: " + player_name)
	
	# Use direct scene change for proper loading
	get_tree().change_scene_to_file("res://scenes/Main/main.tscn")

func _on_continue_button_pressed():
	var loaded_data = SaveSystem.load_game()
	if loaded_data != null and "current_room" in SaveSystem.save_data:
		get_tree().change_scene_to_file("res://scenes/Main/main.tscn")
	else:
		print("Failed to load save data")

func _on_settings_button_pressed():
	var settings_scene = load("res://scenes/Systems/settings.tscn").instantiate()
	
	# Add settings as a child of the current scene
	add_child(settings_scene)
	
	# Set the previous scene to return to
	settings_scene.previous_scene = "res://scenes/Main/Menu/Main_Menu/main_menu.tscn"
	
	# Instead of hiding the entire main menu, just disable interaction
	# This keeps the background visible but prevents clicking
	$MarginContainer.visible = false  # Hide only the UI elements, not the background

func _on_quit_button_pressed():
	get_tree().quit()
