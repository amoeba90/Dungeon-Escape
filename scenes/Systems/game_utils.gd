# game_utils.gd
extends Node # use for individual node fading, sounds, changing scenes, and changing backgrounds

# Fade overlay visibility and opacity
func fade_in(node, duration):
	node.color = Color(0, 0, 0, 255)  # Start fully black
	node.create_timer(duration).set_opacity(0)  # Fade to transparent

func fade_out(node, duration):
	node.color = Color(0, 0, 0, 0)  # Start transparent
	node.create_timer(duration).set_opacity(255)  # Fade to black

# Play a sound effect
func play_sound(audio_player):
	audio_player.play()

# Change scenes
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)

func change_background(background_nodes, visible_node):
	for node in background_nodes:
		node.visible = (node == visible_node)  # Toggle visibility
