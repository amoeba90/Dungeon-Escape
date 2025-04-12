# settings_ui.gd - Attach to your settings.tscn scene
extends Control

# Node references
@onready var master_slider = $Panel/MarginContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var music_slider = $Panel/MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_slider = $Panel/MarginContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var fullscreen_check = $Panel/MarginContainer/VBoxContainer/FullscreenContainer/FullscreenCheck
@onready var resolution_option = $Panel/MarginContainer/VBoxContainer/ResolutionContainer/ResolutionOption

# Previous scene to return to
var previous_scene = "res://scenes/Main/Menu/Main_Menu/main_menu.tscn"

func _ready():
	# Setup UI
	setup_resolution_dropdown()
	load_current_settings()
	connect_signals()

func setup_resolution_dropdown():
	resolution_option.clear()
	for i in range(SettingsManager.resolutions.size()):
		var res = SettingsManager.resolutions[i]
		resolution_option.add_item(str(res.x) + " x " + str(res.y), i)

func load_current_settings():
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

# Signal handlers
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
	SettingsManager.save_settings()
	# Optional: Show a confirmation message
	var confirm = Label.new()
	confirm.text = "Settings saved!"
	confirm.add_theme_color_override("font_color", Color(0, 1, 0))
	$Panel/MarginContainer/VBoxContainer.add_child(confirm)
	await get_tree().create_timer(1.5).timeout
	confirm.queue_free()

func _on_back_button_pressed():
	GameUtils.change_scene(previous_scene)
	queue_free()
