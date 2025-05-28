extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("show_entrance_dialogue")

# Function to show entrance dialogue
func show_entrance_dialogue():
	# Wait a moment for the scene to settle
	await get_tree().create_timer(0.5).timeout
	
	# Show dialogue if no other dialogue is active
	if not DialogueManager.is_dialogue_active():
		DialogueManager.start_dialogue([
			{"text": "This is an unfinished version of Dungeon Escape."},
			{"text": "The full version will be released around May 23rd."},
			{"text": "Please check in to the website for the update!"},
			{"text": "In the meantime, feel free to restart and try out the other doors you haven't opened before."},
			{"text": "Thank you! :3"},
		])
