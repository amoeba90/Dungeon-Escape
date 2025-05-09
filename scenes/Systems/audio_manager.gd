# audio_manager.gd
extends Node

# Audio buses
const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

# Track current music
var current_music_path: String = ""
var current_music_position: float = 0.0
var music_player: AudioStreamPlayer = null
var current_music_volume: float = 0.0

# For tracking settings menu state
var was_in_settings: bool = false
var previous_scene_path: String = ""

# Initialize audio system
func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Connect signals
	music_player.finished.connect(_on_music_finished)

# Main music play function with fade options
func play_music(music_path: String, fade_duration: float = 1.0, volume_db: float = 0.0):
	# Check if this is the same music already playing
	if music_path == current_music_path and music_player.playing:
		return
	
	# Save current path
	current_music_path = music_path
	current_music_volume = volume_db
	
	# Check if we need to fade out current music
	if music_player.playing:
		# Create a tween for fading out
		var fade_out = create_tween()
		fade_out.tween_property(music_player, "volume_db", -80, fade_duration)
		fade_out.tween_callback(_change_music.bind(music_path, volume_db))
	else:
		# No music playing, just start new music
		_change_music(music_path, volume_db)

# Internal function to change the music track
func _change_music(music_path: String, volume_db: float = 0.0):
	# Load new music
	var stream = load(music_path)
	if not stream:
		push_error("Failed to load music: " + music_path)
		return
	
	# Stop current music if playing
	if music_player.playing:
		music_player.stop()
	
	# Set new stream
	music_player.stream = stream
	
	# Set initial volume (silent if fading in)
	music_player.volume_db = -80
	
	# Start playback
	music_player.play()
	
	# Fade in
	var fade_in = create_tween()
	fade_in.tween_property(music_player, "volume_db", volume_db, 1.0)
	
	print("Now playing music: " + music_path)

# Stop music with fade out
func stop_music(fade_duration: float = 1.0):
	if music_player.playing:
		var fade_out = create_tween()
		fade_out.tween_property(music_player, "volume_db", -80, fade_duration)
		fade_out.tween_callback(func(): music_player.stop())
		current_music_path = ""

# Loop music if it finishes
func _on_music_finished():
	if current_music_path != "":
		music_player.play()

# Save music state before scene change
func prepare_for_scene_change():
	# Store position if music is playing
	if music_player.playing:
		current_music_position = music_player.get_playback_position()
		previous_scene_path = get_tree().current_scene.scene_file_path
	
	print("Saved music state: " + current_music_path + " at position " + str(current_music_position))

# Resume music after scene change if appropriate
func handle_scene_loaded(scene_path: String):
	# Don't restart music when going between main menu and settings
	if scene_path == "res://scenes/Systems/settings.tscn":
		was_in_settings = true
		return
		
	# Coming back from settings - don't restart music
	if was_in_settings and previous_scene_path == scene_path:
		was_in_settings = false
		return
		
	# For scene transitions that should keep music playing,
	# you can add more conditions here
	
	# For all other scene changes, restart current music or start new music
	# based on the scene that was loaded

# Play a one-shot sound effect
func play_sfx(sound_path: String, volume_db: float = 0.0):
	if sound_path.strip_edges() == "":
		return
		
	if not ResourceLoader.exists(sound_path):
		push_error("Sound file not found: " + sound_path)
		return
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = load(sound_path)
	sfx_player.volume_db = volume_db
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.play()
	
	# Auto-cleanup when finished
	sfx_player.finished.connect(func(): sfx_player.queue_free())
