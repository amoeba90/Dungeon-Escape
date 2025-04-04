# door.gd
extends Area2D

@export var next_scene_path: String = ""  # Path to the next scene

# Define the properties to avoid errors in `starting_room.gd`
var game_utils  # Reference to the GameUtils Autoload
var fade_overlay  # Reference to the FadeOverlay Autoload

# Called when input is detected within this Area2D
func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):  # Detect left mouse click
		if game_utils:
			game_utils.play_sound($AudioStreamPlayer)  # Call play_sound from game_utils
		if next_scene_path.strip_edges():
			fade_overlay.fade_out(1.0)  # Trigger fade-out animation
			game_utils.change_scene(next_scene_path)  # Change the scene
		else:
			print("Error: next_scene_path is not set or is empty!")
