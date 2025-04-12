# dialogue_manager.gd
extends Node

signal dialogue_ended
signal choice_made(choice_id)

var dialogue_scene = preload("res://scenes/Systems/dialogue_ui.tscn")
var current_dialogue_ui = null
var dialogue_data = []
var current_index = 0
var choice_handlers = {}
var is_active = false

func _ready():
	call_deferred("_setup_dialogue_ui")

func _setup_dialogue_ui():
	# initialize dialogue UI when the game starts
	current_dialogue_ui = dialogue_scene.instantiate()
	get_tree().root.add_child(current_dialogue_ui)
	
	# connect signals
	current_dialogue_ui.choice_selected.connect(_on_choice_selected)

func start_dialogue(data):
	# Store the dialogue data
	dialogue_data = data
	current_index = 0
	is_active = true
	
	# Show dialogue and set initial text
	_show_current_dialogue()

func _show_current_dialogue():
	if current_index < dialogue_data.size():
		var entry = dialogue_data[current_index]
		
		# Check if this is a choice entry
		if "choices" in entry:
			current_dialogue_ui.show_choices(entry.choices)
		else:
			# Regular dialogue entry
			var speaker = entry.get("speaker", "")
			var text = entry.get("text", "")
			current_dialogue_ui.start_dialogue(text, speaker)
	else:
		# No more dialogue
		end_dialogue()

func advance_dialogue():
	current_index += 1
	_show_current_dialogue()

func handle_choice(choice_id):
	if choice_id in choice_handlers:
		choice_handlers[choice_id].call()
	
	# After handling the choice, either advance or branch
	if current_index < dialogue_data.size() and "next_index" in dialogue_data[current_index]:
		current_index = dialogue_data[current_index].next_index
	else:
		current_index += 1
	
	_show_current_dialogue()

func register_choice_handler(choice_id, callback):
	choice_handlers[choice_id] = callback

func _on_choice_selected(choice_id):
	emit_signal("choice_made", choice_id)

func end_dialogue():
	current_dialogue_ui.hide_dialogue()
	is_active = false
	emit_signal("dialogue_ended")

func is_dialogue_active():
	return is_active
