# dean_hallway_3.gd
extends Node2D

var pending_action = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func handle_transition(type: String) -> void:
	# Don't allow new interactions while dialogue is active
	if DialogueManager.is_dialogue_active():
		return
	
	match type:
		"npc":
			DialogueManager.start_dialogue([
				{"speaker": GlobalData.get_player_name(),"text": "Which way is the way out?"},
				{"speaker": "Knight", "text": "I can only tell you that one path leads to salvation. The other leads to a trial with no end."},
				{"speaker": GlobalData.get_player_name(),"text": "Is that all you can tell me?"},
				{"speaker": "Knight", "text": "I have said enough. The choice is yours."}
			])
			pending_action = "npc_done"
			
		"double_door":
			$Background/Background_Original.visible = false
			$Background/Background_DoubleDoorOpen.visible = true

func _on_dialogue_ended():
	match pending_action:
		"npc_done":
			pending_action = ""
