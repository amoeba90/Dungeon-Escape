extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(position != destination)
		
		
	
	pass

func _input(event):
	if Input.is_action_pressed("ui_leftMouseClick")
		destination = get_global_mouse_position()
