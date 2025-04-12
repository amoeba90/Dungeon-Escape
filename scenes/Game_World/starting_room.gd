# starting_room.gd
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# assign game_utils and fade_overlay to the doors
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	
	# assign global references
	left_door.game_utils = GameUtils
	right_door.game_utils = GameUtils
	left_door.fade_overlay = FadeOverlay
	right_door.fade_overlay = FadeOverlay
	
	print("FadeOverlay exists: " + str(FadeOverlay != null))
	
	# start with fade-in effect when entering the scene
	FadeOverlay.fade_in(1.0)

# toggle background visibiility based on the door clicked
func toggle_background_visibility(door: String) -> void:
	if door == "left":
		$Background/Background_Original.visible = false # hide original visual
		$Background/Background_LeftDoorOpen.visible = true # show left door open visual
	elif door == "right":
		$Background/Background_Original.visible = false # hide original visual
		$Background/Background_RightDoorOpen.visible = true # show right door open visual
