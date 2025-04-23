# scene_changer.gd
extends CanvasLayer

signal scene_changed()

@onready var animation_player = $AnimationPlayer
@onready var black = $Control/Black
@onready var input_blocker = $InputBlocker

var is_changing_scene = false
var in_game = false

func _ready():
	in_game = false
	
	if input_blocker:
		input_blocker.visible = false

func change_scene(path):
	# prevent multiple scene changes at once
	if is_changing_scene:
		print("Scene change already in progress")
		return
	
	is_changing_scene = true
	print("Starting scene change to: " + path)
	
	if input_blocker:
		input_blocker.visible = true
	
	# fade to black
	animation_player.play("fade")
	await animation_player.animation_finished
	
	# Check if this is a game world scene path
	if path.begins_with("res://scenes/Game_World/"):
		if not in_game:
			# First time entering game, load Main scene
			print("Loading Main scene")
			var error = get_tree().change_scene_to_file("res://scenes/Main/main.tscn")
			if error != OK:
				print("Error loading Main scene")
				is_changing_scene = false
				if input_blocker:
					input_blocker.visible = false
				return
			
			# Wait for scene to initialize
			await get_tree().process_frame
			in_game = true
			
			# Get Main scene and change room
			var main = get_tree().current_scene
			var room_scene = load(path)
			main.change_room(room_scene)
		else:
			# Already in game, just change room
			var main = get_tree().current_scene
			var room_scene = load(path)
			main.change_room(room_scene)
	else:
		# Not a game scene, regular scene change
		print("Loading non-game scene")
		in_game = false
		var error = get_tree().change_scene_to_file(path)
		if error != OK:
			print("Error changing scene")
			is_changing_scene = false
			if input_blocker:
				input_blocker.visible = false
			return
	
	# fade back in
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	
	if input_blocker:
		input_blocker.visible = false
	print("Scene change complete")
	is_changing_scene = false
	emit_signal("scene_changed")
