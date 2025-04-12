extends Node

signal dialogue_ended

var dialogue_scene = preload("res://scenes/Systems/dialogue_ui.tscn")
var current_dialogue_ui = null
var dialogue_data = []
var current_index = 0

func start_dialogue(data):
	# Store the dialogue data
	dialogue_data = data
	current_index = 0
	
	# Create dialogue UI if it doesn't exist
	if not current_dialogue_ui:
		current_dialogue_ui = dialogue_scene.instantiate()
		get_tree().root.add_child(current_dialogue_ui)
	
	# Show dialogue and set initial text
	current_dialogue_ui.visible = true
	_show_current_dialogue()

func _show_current_dialogue():
	if current_index < dialogue_data.size():
		var entry = dialogue_data[current_index]
		
		# Update speaker name
		if "speaker" in entry and entry.speaker != "":
			current_dialogue_ui.show_speaker(entry.speaker)
		else:
			current_dialogue_ui.hide_speaker()
		
		# Set dialogue text
		current_dialogue_ui.set_text(entry.text)
	else:
		# No more dialogue
		end_dialogue()

func advance_dialogue():
	current_index += 1
	_show_current_dialogue()

func show_choices(choices):
	current_dialogue_ui.show_choices(choices)

func end_dialogue():
	if current_dialogue_ui:
		current_dialogue_ui.visible = false
	emit_signal("dialogue_ended")

func is_dialogue_active():
	return current_dialogue_ui != null and current_dialogue_ui.visible
