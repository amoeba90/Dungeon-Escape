# next_room.gd
extends Area2D

@export var next_scene_path: String = ""  # Path to the next scene
@export var sound_path: String = "" # Path to the sound file played

var game_utils
var fade_overlay

func _ready():
	# Explicitly connect the input_event signal
	connect("input_event", Callable(self, "_on_input_event"))

# Called when input is detected within this Area2D
func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):  # Detect left mouse click
		
		play_custom_sound() # Play sound for door/arrow
		
		if next_scene_path.strip_edges():
			fade_overlay.fade_out(1.0)  # Trigger fade-out animation
			game_utils.change_scene(next_scene_path)  # Change the scene
		else:
			print("Error: next_scene_path is not set or is empty!")

func play_custom_sound():
	if sound_path.strip_edges() != "":
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = load(sound_path) # load the specified sound
		add_child(audio_player) # add the auadio player to this node
		audio_player.play() #play the sound
		audio_player.connect("finished", Callable(self, "_on_audio_finished"))
	else:
		print("Error: No sound file specified for this door")

func _on_audio_finished(audio_player) -> void:
	audio_player.queue_free() #free audiostreamplayer after playback
