# dean_entrance_blocked
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the arrow's Area2D
	var down_arrow = $InteractiveAreas/DownArrow_Area
	
	# assign global references
	down_arrow.game_utils = GameUtils
	down_arrow.fade_overlay = FadeOverlay
	
	# start with fade-in effect when entering the scene
	FadeOverlay.fade_in(1.0)
