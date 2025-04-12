# settings_manager.gd - Autoload as SettingsManager
extends Node

# Settings values
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var fullscreen: bool = false
var resolution_index: int = 1

# Constants
const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2
var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

func _ready():
	load_settings()
	apply_settings()

# Core functionality
func apply_settings():
	# Audio
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(master_volume))
	if AudioServer.get_bus_count() > MUSIC_BUS:
		AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))
	if AudioServer.get_bus_count() > SFX_BUS:
		AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(sfx_volume))
	
	# Display
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if resolution_index >= 0 and resolution_index < resolutions.size():
		DisplayServer.window_set_size(resolutions[resolution_index])
		center_window()

# Helper methods
func center_window():
	if !fullscreen:
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position((screen_size - window_size) / 2)

func linear_to_db(linear_value):
	return -80.0 if linear_value < 0.01 else 20.0 * log(linear_value) / log(10.0)

func db_to_linear(db_value):
	return pow(10.0, db_value / 20.0)

# Save/load functionality
func save_settings():
	var settings = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"fullscreen": fullscreen,
		"resolution_index": resolution_index
	}
	
	var settings_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if settings_file:
		settings_file.store_string(JSON.stringify(settings))
	else:
		print("Error: Could not save settings")

func load_settings():
	if FileAccess.file_exists("user://settings.json"):
		var settings_file = FileAccess.open("user://settings.json", FileAccess.READ)
		if settings_file:
			var settings = JSON.parse_string(settings_file.get_as_text())
			if typeof(settings) == TYPE_DICTIONARY:
				# Load values with fallbacks
				master_volume = settings.get("master_volume", 1.0)
				music_volume = settings.get("music_volume", 1.0)
				sfx_volume = settings.get("sfx_volume", 1.0)
				fullscreen = settings.get("fullscreen", false)
				resolution_index = settings.get("resolution_index", 1)
			else:
				print("Error: Settings file is not valid")
		else:
			print("Error: Could not open settings file")
