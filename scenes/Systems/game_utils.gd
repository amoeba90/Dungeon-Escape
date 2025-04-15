# game_utils.gd
extends Node # use for sounds, changing scenes, and changing backgrounds

# Play a sound effect
func play_sound(audio_player):
	audio_player.play()

# Change scenes
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)

func change_background(background_nodes, visible_node):
	for node in background_nodes:
		node.visible = (node == visible_node)  # Toggle visibility
