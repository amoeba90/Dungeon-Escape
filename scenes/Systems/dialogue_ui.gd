# dialogue_ui.gd
extends Control

signal choice_selected(choice_id)

# Node references
@onready var dialogue_container = $CanvasLayer/DialogueContainer
@onready var dialogue_box = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox
@onready var speaker_box = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/SpeakerBox
@onready var speaker_label = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/SpeakerBox/MarginContainer/SpeakerLabel
@onready var dialogue_text = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/MarginContainer/HBoxContainer/DialogueText
@onready var choices_panel = $CanvasLayer/ChoicesPanel
@onready var choices_container = $CanvasLayer/ChoicesPanel/ChoicesContainer

# Text display variables
var full_text = ""
var displayed_text = ""
var char_index = 0
var display_speed = 0.03  # seconds per character
var is_typing = false
var can_advance = false

func _ready():
	# Hide elements initially
	dialogue_container.visible = false
	speaker_box.visible = false
	choices_panel.visible = false
	
	# Set up input detection for the dialogue box
	dialogue_container.gui_input.connect(_on_dialogue_input)
	
	# add a full-screen inpupt blocker when dialogue is active
	var input_blocker = Control.new()
	input_blocker.name = "InputBlocker"
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	input_blocker.anchor_right = 1.0
	input_blocker.anchor_bottom = 1.0
	input_blocker.visible = false
	$CanvasLayer.add_child(input_blocker)
	
	input_blocker.gui_input.connect(_on_dialogue_input)

func _process(delta):
	if is_typing:
		# Character-by-character text display
		if char_index < full_text.length():
			var next_char_timer = get_node_or_null("NextCharTimer")
			if not next_char_timer:
				next_char_timer = Timer.new()
				next_char_timer.name = "NextCharTimer"
				next_char_timer.one_shot = true
				next_char_timer.timeout.connect(_type_next_character)
				add_child(next_char_timer)
				next_char_timer.start(display_speed)

func _type_next_character():
	if char_index < full_text.length():
		char_index += 1
		displayed_text = full_text.substr(0, char_index)
		dialogue_text.text = displayed_text
		
		if char_index < full_text.length():
			# Set up timer for next character
			var timer = Timer.new()
			timer.one_shot = true
			timer.wait_time = display_speed
			timer.timeout.connect(func(): _type_next_character())
			add_child(timer)
			timer.start()
		else:
			# Typing finished
			is_typing = false
			can_advance = true

func _on_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			# Skip typing animation and show full text
			char_index = full_text.length()
			displayed_text = full_text
			dialogue_text.text = displayed_text
			is_typing = false
			can_advance = true
		elif can_advance:
			# Advance to next dialogue line
			DialogueManager.advance_dialogue()

func start_dialogue(text, speaker=""):
	$CanvasLayer/InputBlocker.visible = true
	
	print("Starting dialogue with text: " + text)
	print ("Speaker: " + speaker)
	# Reset variables
	full_text = text
	displayed_text = ""
	char_index = 0
	is_typing = true
	can_advance = false
	
	# Show/hide speaker box based on whether there's a speaker
	if speaker != "":
		speaker_box.visible = true
		speaker_label.text = speaker
	else:
		speaker_box.visible = false
	
	# Show dialogue container
	dialogue_container.visible = true
	
	# Start typing effect
	_type_next_character()

func show_choices(choices):
	# Clear existing choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Create buttons for each choice
	for choice in choices:
		var button = Button.new()
		button.text = choice.text
		button.custom_minimum_size = Vector2(300, 50)
		
		#style the choice buttons
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = Color(1, 1, 1, 1) # white background
		button_style.border_width_left = 2
		button_style.border_width_top = 2
		button_style.border_width_right = 2
		button_style.border_width_bottom = 2
		button_style.border_color = Color(0, 0, 0, 1)  # Black border
		button_style.corner_radius_top_left = 5
		button_style.corner_radius_top_right = 5
		button_style.corner_radius_bottom_left = 5
		button_style.corner_radius_bottom_right = 5
		
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_color_override("font_color", Color(0, 0, 0, 1)) # black text
		
		button.pressed.connect(_on_choice_selected.bind(choice.id))
		choices_container.add_child(button)
	
	choices_panel.visible = true

func hide_choices():
	choices_panel.visible = false

func _on_choice_selected(choice_id):
	hide_choices()
	emit_signal("choice_selected", choice_id)
	DialogueManager.handle_choice(choice_id)

func hide_dialogue():
	dialogue_container.visible = false
	choices_panel.visible = false
	$CanvasLayer/InputBlocker.visible = false
