# settings_ui.gd - Attach to your settings.tscn scene
extends Control

# Node references
@onready var master_slider = $Panel/MarginContainer/VBoxContainer/SettingsContainner/MasterVolumeContainer/MasterVolumeSlider
@onready var music_slider = $Panel/MarginContainer/VBoxContainer/SettingsContainner/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_slider = $Panel/MarginContainer/VBoxContainer/SettingsContainner/SFXVolumeContainer/SFXVolumeSlider
@onready var fullscreen_check = $Panel/MarginContainer/VBoxContainer/SettingsContainner/FullScreenContainer/FullscreenCheck
@onready var resolution_option = $Panel/MarginContainer/VBoxContainer/SettingsContainner/ResolutionContainer/ResolutionOption
@onready var apply_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/ApplyButton

# Previous scene to return to
var previous_scene = "res://scenes/Main/Menu/Main_Menu/main_menu.tscn"
var opened_from_pause_menu = false

# Store original settings to revert if needed
var original_master_volume = 0
var original_music_volume = 0
var original_sfx_volume = 0
var original_fullscreen = false
var original_resolution_index = 0
var settings_saved = false

func _ready():
	# Make sure settings UI processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Detect if we were opened from the pause menu
	opened_from_pause_menu = get_tree().paused
	print("Settings opened from pause menu: ", opened_from_pause_menu)
	
	# Setup UI
	setup_resolution_dropdown()
	store_original_settings()
	load_current_settings()
	connect_signals()

func setup_resolution_dropdown():
	resolution_option.clear()
	for i in range(SettingsManager.resolutions.size()):
		var res = SettingsManager.resolutions[i]
		resolution_option.add_item(str(res.x) + " x " + str(res.y), i)

func store_original_settings():
	# Store the original settings to revert if needed
	original_master_volume = SettingsManager.master_volume
	original_music_volume = SettingsManager.music_volume
	original_sfx_volume = SettingsManager.sfx_volume
	original_fullscreen = SettingsManager.fullscreen
	original_resolution_index = SettingsManager.resolution_index

func load_current_settings():
	# Load the current settings into the UI
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	resolution_option.select(SettingsManager.resolution_index)

func connect_signals():
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)

# Signal handlers - apply settings immediately
func _on_master_volume_changed(value):
	SettingsManager.master_volume = value
	SettingsManager.apply_settings()

func _on_music_volume_changed(value):
	SettingsManager.music_volume = value
	SettingsManager.apply_settings()

func _on_sfx_volume_changed(value):
	SettingsManager.sfx_volume = value
	SettingsManager.apply_settings()

func _on_fullscreen_toggled(button_pressed):
	SettingsManager.fullscreen = button_pressed
	SettingsManager.apply_settings()

func _on_resolution_selected(index):
	SettingsManager.resolution_index = index
	SettingsManager.apply_settings()

func _on_apply_button_pressed():
	print("Apply button pressed")
	
	# Save the settings permanently
	SettingsManager.save_settings()
	settings_saved = true
	
	# Show confirmation message
	var confirm = Label.new()
	confirm.text = "Settings saved!"
	confirm.add_theme_color_override("font_color", Color(0, 1, 0))
	$Panel/MarginContainer/VBoxContainer.add_child(confirm)
	await get_tree().create_timer(1.5).timeout
	confirm.queue_free()

func _on_back_button_pressed():
	# If settings weren't saved, revert to original
	if not settings_saved:
		print("Reverting settings to original values")
		SettingsManager.master_volume = original_master_volume
		SettingsManager.music_volume = original_music_volume
		SettingsManager.sfx_volume = original_sfx_volume
		SettingsManager.fullscreen = original_fullscreen
		SettingsManager.resolution_index = original_resolution_index
		SettingsManager.apply_settings()
	
	if opened_from_pause_menu:
		# We're in the game, returning to pause menu
		print("Returning to pause menu")
		
		# Find pause menu in the scene tree
		var main = get_node_or_null("/root/Main")
		if main and main.pause_menu_instance:
			main.pause_menu_instance.visible = true
			
			# Ensure game stays paused
			get_tree().paused = true
		else:
			print("Warning: Couldn't find pause menu, pausing the game anyway")
			get_tree().paused = true
		
		# Remove settings menu
		queue_free()
	else:
		# We're in the main menu, use normal scene change
		print("Returning to previous scene: ", previous_scene)
		# Make sure game is unpaused when returning to main menu
		get_tree().paused = false
		GameUtils.change_scene(previous_scene)
		queue_free()
