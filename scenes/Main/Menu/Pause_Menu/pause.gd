# pause.gd
extends Control

signal pause_menu_closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_Resume_Button_pressed():
	toggle_pause_menu()

func toggle_pause_menu():
	var was_visible = self.visible
	self.visible = !self.visible # toggle visibility
	get_tree().paused = self.visible # pause/unpause game tree
	
	if was_visible: 
		emit_signal("pause_menu_closed")

func _on_Save_Button_pressed():
	SaveSystem.save_game()

func _on_Settings_Button_pressed():
	var settings_scene = load("res://scenes/Systems/settings.tscn").instantiate()
	get_tree().root.add_child(settings_scene)
	# set the previous scene to return to
	settings_scene.previous_scene = get_tree().current_scene.scene_file_path
	self.visible = false

func _on_Main_Menu_Button_pressed():
	# Important: Disable pause menu and unpause game BEFORE changing scenes
	self.visible = false
	get_tree().paused = false
	
	# Now change to main menu
	GameUtils.change_scene("res://scenes/Main/Menu/Main_Menu/main_menu.tscn")
