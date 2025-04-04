# pause.gd
extends Popup

var save_system

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_system = get_node("/root/Main/SaveSystem") # path to access SaveSystem

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_Resume_Button_pressed():
	toggle_pause_menu()

func toggle_pause_menu():
	self.visible = !self.visible # toggle visibility
	get_tree().paused = self.visible # pause/unpause game tree

func _on_Save_Button_pressed():
	save_system.save_game()

func _on_Settings_Button_pressed():
	print("Settings button pressed") # temp debug line

func _on_Main_Menu_Button_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
