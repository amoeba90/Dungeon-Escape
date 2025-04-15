# scene_changer.gd
extends CanvasLayer

signal scene_changed()

@onready var animation_player = $AnimationPlayer
@onready var black = $Control/Black

var is_changing_scene = false

func change_scene(path):
	# prevent multiple scene changes at once
	if is_changing_scene:
		print("Scene change already in progress")
		return
	
	is_changing_scene = true
	
	# fade to black
	animation_player.play("fade")
	await animation_player.animation_finished
	
	# change scene
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		print("Error changing scene: " + str(error))
		is_changing_scene = false
		return
	
	# fade back in
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	
	is_changing_scene = false
	emit_signal("scene_changed")
