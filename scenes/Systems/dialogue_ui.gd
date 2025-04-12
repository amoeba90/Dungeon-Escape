# dialogue_ui.gd
extends Control

signal choice_selected(choice_id)

# Node references
@onready var dialogue_container = $CanvasLayer/DialogueContainer
@onready var dialogue_box = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox
@onready var speaker_box = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/SpeakerBox
@onready var speaker_label = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/SpeakerBox/MarginContainer/SpeakerLabel
@onready var dialogue_text = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/MarginContainer/HBoxContainer/DialogueText
@onready var continue_arrow = $CanvasLayer/DialogueContainer/VBoxContainer/DialogueBox/MarginContainer/HBoxContainer/ContinueArrow
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
	continue_arrow.visible = false
	choices_panel.visible = false
	
	# Set up input detection for the dialogue box
	dialogue_box.gui_input.connect(_on_dialogue_input)
	
	# Setup arrow animation
	setup_arrow_animation()

func setup_arrow_animation():
	var animation_player = AnimationPlayer.new()
	continue_arrow.add_child(animation_player)
	animation_player.name = "AnimationPlayer"
	
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":scale")
	animation.track_insert_key(track_index, 0.0, Vector2(1, 1))
	animation.track_insert_key(track_index, 0.5, Vector2(1.2, 1.2))
	animation.track_insert_key(track_index, 1.0, Vector2(1, 1))
	animation.loop_mode = Animation.LOOP_LINEAR
	
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("pulse", animation)
	animation_player.add_animation_library("", animation_library)

func _process(delta):
	if is_typing:
		# Character-by-character text display
		if char_index < full_text.length():
			var next_char_timer = get_node_or_null("NextCharTimer")
			if not next_char_timer:
				next_char_timer = Timer.new()
				next_char_timer.name = "NextCharTimer"
				next_char_timer.one_shot = true
				next_char_timer.timeout.connect(_display_next_char)
				add_child(next_char_timer)
				next_char_timer.start(display_speed)

func _display_next_char():
	if char_index < full_text.length():
		char_index += 1
		displayed_text = full_text.substr(0, char_index)
		dialogue_text.text = displayed_text
		
		# Continue typing if not done
		if char_index < full_text.length():
			$NextCharTimer.start(display_speed)
		else:
			# Typing finished
			is_typing = false
			can_advance = true
			continue_arrow.visible = true
			continue_arrow.get_node("AnimationPlayer").play("pulse")

func _on_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			# Skip typing animation and show full text
			char_index = full_text.length()
			displayed_text = full_text
			dialogue_text.text = displayed_text
			is_typing = false
			can_advance = true
			continue_arrow.visible = true
			continue_arrow.get_node("AnimationPlayer").play("pulse")
		elif can_advance:
			# Advance to next dialogue line
			DialogueManager.advance_dialogue()

func start_dialogue(text, speaker=""):
	# Reset variables
	full_text = text
	displayed_text = ""
	char_index = 0
	is_typing = true
	can_advance = false
	
	# Hide the arrow until typing completes
	continue_arrow.visible = false
	if continue_arrow.has_node("AnimationPlayer"):
		continue_arrow.get_node("AnimationPlayer").stop()
	
	# Show/hide speaker box based on whether there's a speaker
	if speaker != "":
		speaker_box.visible = true
		speaker_label.text = speaker
	else:
		speaker_box.visible = false
	
	# Show dialogue container
	dialogue_container.visible = true
	
	# Start typing effect
	_display_next_char()

func show_choices(choices):
	# Clear existing choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Create buttons for each choice
	for choice in choices:
		var button = Button.new()
		button.text = choice.text
		button.custom_minimum_size = Vector2(300, 50)
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
	if continue_arrow.has_node("AnimationPlayer"):
		continue_arrow.get_node("AnimationPlayer").stop()
