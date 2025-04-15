# dean_hallway_2
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# assign game_utils and fade_overlay to the doors
	var left_door = $InteractiveAreas/LeftDoor_Area
	var right_door = $InteractiveAreas/RightDoor_Area
	var double_door = $InteractiveAreas/DoubleDoor_Area
	var down_arrow = $InteractiveAreas/DownArrow_Area

# toggle background visibiility based on the door clicked
func handle_transition(type: String) -> void:
	match type:
		"left_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_LeftDoorOpen.visible = true # show left door open visual
		"right_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_RightDoorOpen.visible = true # show right door open visual
		"double_door":
			$Background/Background_Original.visible = false # hide original visual
			$Background/Background_DoubleDoorOpen.visible = true # show right door open visual
