# main.gd
extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func change_room(new_room_scene: PackedScene):
	# error handling
	if new_room_scene == null:
		print("Error: Room Scene not provided")
		return # exit function
	# save current room state before transition
	SaveSystem.save_data["current_room"] =  new_room_scene.resource_path
	SaveSystem.save_game()
	# temporary debug code
	print("Changing to room: ", new_room_scene.resource_path)
	# free the current room
	if $GameWorld/CurrentRoom:
		$GameWorld/CurrentRoom.queue_free()
	# instanciate the new room
	var next_room = new_room_scene.instance()
	$GameWorld.add_child(next_room)
