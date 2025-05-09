# player_name_customization.gd
extends Control

signal name_confirmed(player_name)
var previous_scene = "" # To track which scene to return to

# Called when the node enters the scene tree for the first time.
func _ready():	
	# Set focus to the input field
	$Panel/MarginContainer/VBoxContainer/NameContainer/NameInput.grab_focus()
	
	# Make sure this UI processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_text_changed(new_text):
	# Only allow letters and numbers
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9]*$")
	var error_label = $Panel/MarginContainer/VBoxContainer/ErrorLabel
	
	if regex.search(new_text) == null and new_text != "":
		# Invalid characters detected
		error_label.text = "Only letters and numbers allowed"
		error_label.visible = true
		
		# Remove invalid characters
		var valid_text = ""
		var name_input = $Panel/MarginContainer/VBoxContainer/NameContainer/NameInput
		
		# Check each character and only keep alphanumeric ones
		for ch in new_text:
			# Check if character is a letter or number
			if (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or (ch >= '0' and ch <= '9'):
				valid_text += ch
		
		# Set the sanitized text (this will trigger _on_text_changed again)
		name_input.text = valid_text
		# Maintain cursor position
		name_input.caret_column = valid_text.length()
	else:
		# Valid input, hide error
		error_label.visible = false

func _on_confirm_button_pressed():
	var name_input = $Panel/MarginContainer/VBoxContainer/NameContainer/NameInput
	var player_name = name_input.text.strip_edges()
	
	# Use a default name if nothing was entered
	if player_name.is_empty():
		player_name = "Adventurer"
	
	# Set the player name immediately
	GlobalData.set_player_name(player_name)
	
	# Emit signal with the name
	emit_signal("name_confirmed", player_name)
	
	# Remove self
	queue_free()

func _on_back_button_pressed():
	# Make sure the main menu is visible again
	var main_menu = get_tree().root.get_node_or_null("MainMenu")
	if main_menu:
		main_menu.visible = true
	
	# Remove the popup
	queue_free()
