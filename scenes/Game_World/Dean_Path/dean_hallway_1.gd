# dean_hallway_1
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# assign game_utils and fade_overlay to the doors
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	var down_arrow = $InteractiveAreas/DownArrow_Area
	
	# assign global references
	left_door.game_utils = GameUtils
	left_door.fade_overlay = FadeOverlay
	right_door.game_utils = GameUtils
	right_door.fade_overlay = FadeOverlay
	down_arrow.game_utils = GameUtils
	down_arrow.fade_overlay = FadeOverlay

	# start with fade-in effect when entering the scene
	FadeOverlay.fade_in(1.0)
