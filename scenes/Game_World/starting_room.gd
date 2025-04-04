# starting_room.gd
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# assign game_utils and fade_overlay to the doors
	var left_door = $CanvasLayer/LeftDoor_Area
	var right_door = $CanvasLayer/RightDoor_Area
	# assign global references
	left_door.game_utils = GameUtils
	right_door.game_utils = GameUtils
	left_door.fade_overlay = FadeOverlay
	right_door.fade_overlay = FadeOverlay

# toggle background visibiility based on the door clicked
func toggle_background_visibility(door: String) -> void:
	if door == "left":
		$CanvasLayer/Background_Original.visible = false # hide original visual
		$CanvasLayer/Background_LeftDoorOpen.visible = true # show left door open visual
	elif door == "right":
		$CanvasLayer/Background_Original.visible = false # hide original visual
		$CanvasLayer/Background_RightDoorOpen.visible = true # show right door open visual
