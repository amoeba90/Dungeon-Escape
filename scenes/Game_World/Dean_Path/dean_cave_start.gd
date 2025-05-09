# dean_cave_start.gd
extends Node2D

var enemy_defeated = false
var cave_door_unlocked = false
var pending_action = ""

# Path to the room the cave door leads to
const LOCKED_ROOM_PATH = "res://scenes/Game_World/Dean_Path/dean_cave_crossroads.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_cave_start" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_cave_start"]
		
		if "enemy_defeated" in room_state and room_state["enemy_defeated"]:
			enemy_defeated = true
		
		if "cave_door_unlocked" in room_state and room_state["cave_door_unlocked"]:
			cave_door_unlocked = true
			print("Loaded saved state: Cave door is unlocked")
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func fight_sequence():
	#wait half a second
	$Background/Background_ZombieStart.visible = false
	$Background/Background_ZombieMiddle.visible = true
	#wait half a second
	$Background/Background_ZombieMiddle.visible = false
	$Background/Background_ZombieStop.visible = true
	
	# if has sword in inventory:
		$Background/Background_ZombieStop.visible = false
		$Background/Background_ZombieHit.visible = true
		
		$Background/Background_ZombieHit.visible = false
		$Background/Background_ZombieDeadCrystal.visible = true
		
		enemy_defeated = true
	# else:
		#fade to death menu with tip: "You might need a certain item before you can defeat an enemy" (not implemented yet i think)

func handle_transition(type: String) -> void:
	match type:
		"crystal":
			if enemy_defeated:
				# pickup crystal
				# play dialogue
				pending_action = "crystal_done"
				$Background/Background_ZombieDeadCrystal.visible = false
				$Background/Background_ZombieDead.visible = true
		"cave_door":
			var cave_door = $InteractiveAreas/CaveDoor_Area
			if enemy_defeated:
				cave_door.next_scene_path = LOCKED_ROOM_PATH


func _on_dialogue_ended():
	match pending_action:
		"crystal_done":
			pending_action = ""
