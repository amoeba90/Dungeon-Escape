# dean_cave_boss.gd
extends Node2D

var enemy_defeated = false
var pending_action = ""
var qte_timer = null
var qte_active = false

# Path to the room the cave door leads to
const LOCKED_ROOM_PATH = "res://scenes/Game_World/Dean_Path/dean_escape.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load saved state if it exists
	if "room_states" in SaveSystem.save_data and "dean_cave_boss" in SaveSystem.save_data["room_states"]:
		var room_state = SaveSystem.save_data["room_states"]["dean_cave_boss"]
		
		if "enemy_defeated" in room_state and room_state["enemy_defeated"]:
			enemy_defeated = true
			# Set visual state to dead spider
			$Background/Background_Original.visible = false
			$Background/Background_SpiderDead.visible = true
			
			# Unlock the cave door
			var cave_door = $InteractiveAreas/CaveDoor_Area
			cave_door.next_scene_path = LOCKED_ROOM_PATH
			print("Loaded saved state: Spider already defeated")
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.choice_made.connect(_on_choice_made)
	
	# If spider hasn't been defeated yet, start the encounter automatically
	if not enemy_defeated:
		call_deferred("fight_sequence")

func fight_sequence():
	# Wait a moment for the scene to fully load
	await get_tree().create_timer(1.0).timeout
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "A spider? This must be the dungeon boss!"}
	])
	await DialogueManager.dialogue_ended
	
	# Start quick time event
	start_qte()

func start_qte():
	qte_active = true
	
	# Create available choices based on inventory
	var choices = [
		{"id": "torch", "text": "TORCH"}
	]
	
	# Add other items if player has them
	if InventoryUtils.has_item("sword"):
		choices.append({"id": "sword", "text": "SWORD"})
	if InventoryUtils.has_item("crystal"):
		choices.append({"id": "crystal", "text": "CRYSTAL"})
	if InventoryUtils.has_item("hammer"):
		choices.append({"id": "hammer", "text": "HAMMER"})
	
	# Show choices with timer
	DialogueManager.start_dialogue([
		{"choices": choices}
	])
	
	# Start countdown timer (5 seconds)
	create_qte_timer()

func create_qte_timer():
	# Create timer UI element
	var timer_ui = Control.new()
	timer_ui.name = "QTE_Timer"
	timer_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(timer_ui)
	
	# Background for timer bar
	var timer_bg = ColorRect.new()
	timer_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	timer_bg.size = Vector2(600, 40)
	timer_bg.position = Vector2(660, 50)  # Top center of screen
	timer_ui.add_child(timer_bg)
	
	# Timer bar that moves
	var timer_bar = ColorRect.new()
	timer_bar.name = "TimerBar"
	timer_bar.color = Color(1, 0, 0, 1)  # Red
	timer_bar.size = Vector2(600, 40)
	timer_bar.position = Vector2(660, 50)
	timer_ui.add_child(timer_bar)
	
	# Animate timer bar from right to left
	var tween = create_tween()
	tween.tween_property(timer_bar, "size:x", 0, 5.0)  # 5 second countdown
	tween.tween_callback(qte_timeout)

func qte_timeout():
	if qte_active:
		qte_active = false
		# Remove timer UI
		var timer_ui = get_node_or_null("QTE_Timer")
		if timer_ui:
			timer_ui.queue_free()
		
		# Hide choices and show spider attack
		DialogueManager.end_dialogue()
		spider_attack_death()

func _on_choice_made(choice_id):
	if not qte_active:
		return
		
	qte_active = false
	
	# Remove timer UI
	var timer_ui = get_node_or_null("QTE_Timer")
	if timer_ui:
		timer_ui.queue_free()
	
	match choice_id:
		"torch":
			# Correct choice - defeat spider
			defeat_spider()
		"sword", "crystal", "hammer":
			# Wrong choice - spider knocks it away and kills you
			wrong_choice_death(choice_id)

func defeat_spider():
	# Victory sequence
	await get_tree().create_timer(0.5).timeout
	$Background/Background_Original.visible = false
	$Background/Background_SpiderHit.visible = true
	
	# Play torch attack sound
	AudioManager.play_sfx("res://assets/Audio/SFX/fire_attack.ogg")
	
	await get_tree().create_timer(1.0).timeout
	$Background/Background_SpiderHit.visible = false
	$Background/Background_SpiderFall.visible = true
	
	await get_tree().create_timer(1.0).timeout
	$Background/Background_SpiderFall.visible = false
	$Background/Background_SpiderDead.visible = true
	
	# Play spider death sound
	AudioManager.play_sfx("res://assets/Audio/SFX/spider_death.ogg")
	
	enemy_defeated = true
	
	# Unlock the cave door
	var cave_door = $InteractiveAreas/CaveDoor_Area
	cave_door.next_scene_path = LOCKED_ROOM_PATH
	
	save_room_state()
	
	# Show victory dialogue
	DialogueManager.start_dialogue([
		{"speaker": GlobalData.get_player_name(), "text": "I defeated the spider boss!"},
		{"speaker": GlobalData.get_player_name(), "text": "The exit should be just ahead!"}
	])

func wrong_choice_death(choice_id):
	# Get item name for dialogue
	var item_name = choice_id.capitalize()
	
	# Show dialogue about spider knocking item away
	DialogueManager.start_dialogue([
		{"text": "The spider hits the " + item_name + " out of your hand!"}
	])
	await DialogueManager.dialogue_ended
	
	# Show spider attack and death
	spider_attack_death()

func spider_attack_death():
	$Background/Background_Original.visible = false
	$Background/Background_SpiderAttack.visible = true
	
	await get_tree().create_timer(1.0).timeout
	show_death_menu()

func show_death_menu():
	# Load and show death menu scene
	var death_menu_scene = preload("res://scenes/Main/Menu/Death_Menu/death_menu.tscn")
	var death_menu = death_menu_scene.instantiate()
	get_tree().root.add_child(death_menu)
	
	# Pause the game
	get_tree().paused = true

func handle_transition(type: String) -> void:
	if DialogueManager.is_dialogue_active() or qte_active:
		return
	
	match type:
		"spider":
			if enemy_defeated:
				# Spider is already dead
				DialogueManager.start_dialogue([
					{"speaker": GlobalData.get_player_name(), "text": "The spider boss has been defeated."}
				])
		"cave_door":
			# Cave door is automatically unlocked after defeating spider
			pass

func _on_dialogue_ended():
	match pending_action:
		_:
			pending_action = ""

func save_room_state():
	if not "room_states" in SaveSystem.save_data:
		SaveSystem.save_data["room_states"] = {}
	
	var room_state = {
		"enemy_defeated": enemy_defeated
	}
	
	SaveSystem.save_data["room_states"]["dean_cave_boss"] = room_state
	SaveSystem.save_game()
