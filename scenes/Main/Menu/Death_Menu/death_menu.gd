# death_menu.gd
extends Popup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_New_Game_Button_pressed():
	pass
func _on_Try_Again_Button_pressed():
	pass

func _on_Settings_Button_pressed():
	print("Settings button pressed") # temp debug line

func _on_Main_Menu_Button_pressed():
	get_tree().paused = false
	GameUtils.change_scene("res://scenes/Main/Menu/Main_Menu/main_menu.tscn")
