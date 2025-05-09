# main.gd
extends Node

# References to ui elements
@onready var inventory_button = $UI/Top_Bar/Inventory_Button
@onready var pause_button = $UI/Top_Bar/Pause_Button

# Referencces to scenes
var inventory_scene = preload("res://scenes/Systems/inventory.tscn")
var pause_menu_scene = preload("res://scenes/Main/Menu/Pause_Menu/pause.tscn")

# References
var inventory_instance = null
var is_inventory_open = false
var active_item_data = null
var pause_menu_instance = null

func _ready():
	# Initialize UI elements
	_init_pause_menu()
	_init_inventory()
	
	# Check if SceneChanger is in the middle of loading a specific room
	if get_node_or_null("/root/SceneChanger") and SceneChanger.is_changing_scene:
		# Don't load anything - SceneChanger will handle it
		print("SceneChanger is active - skipping initial room load")
	else:
		# Load the room specified in SaveSystem
		print("Loading initial room from save data")
		if SaveSystem.save_data.has("current_room") and SaveSystem.save_data["current_room"] != "":
			var room_scene = load(SaveSystem.save_data["current_room"])
			change_room(room_scene)
		else:
			print("No room specified in save data")

func _init_pause_menu():
	pause_menu_instance = pause_menu_scene.instantiate()
	add_child(pause_menu_instance)
	pause_menu_instance.visible = false
	
	# Only the pause menu should work during pause
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS

func _init_inventory():
	inventory_instance = inventory_scene.instantiate()
	add_child(inventory_instance)
	
	# Set initial state (hidden)
	inventory_instance.position = Vector2(2100, 540)  # Off-screen position
	inventory_instance.visible = false
	
	# Connect signals
	inventory_instance.inventory_closed.connect(_on_inventory_closed)

func _on_pause_button_pressed():	
	print("Pause button pressed")
	if pause_menu_instance:
		pause_menu_instance.toggle_pause_menu()
	else:
		print("Error: pause_menu_instance is null")

func _on_inventory_button_pressed():
	print("Inventory button pressed")
	if inventory_instance:
		# Load the inventory content before showing
		inventory_instance.load_inventory()
		
		# Toggle visibility using inventory's own function
		inventory_instance.toggle_visibility()
		
		# Update state tracking in Main
		is_inventory_open = inventory_instance.is_visible
		
		var status_text = "closed"
		if is_inventory_open:
			status_text = "open"
		print("Inventory toggled, is now: ", status_text)
	else:
		print("Error: inventory_instance is null")

func _on_inventory_closed():
	# Update button state
	is_inventory_open = false
	
	# Reset active item if any
	active_item_data = null

# Function to handle room transitions
func change_room(new_room_scene: PackedScene):
	if new_room_scene == null:
		print("Error: Room Scene not provided")
		return
		
	SaveSystem.save_data["current_room"] = new_room_scene.resource_path
	SaveSystem.save_game()
	
	print("Changing to room: ", new_room_scene.resource_path)
	
	# Hide inventory if it's open when changing rooms
	if is_inventory_open and inventory_instance:
		inventory_instance.is_visible = false  # Set the state directly
		inventory_instance.visible = false     # Hide it directly
		inventory_instance.position = Vector2(2100, 540)  # Move it off screen
		is_inventory_open = false
	
	# IMPORTANT: Properly clean up all existing rooms
	for child in $GameWorld.get_children():
		print("Removing existing room: ", child.name)
		child.queue_free()
	
	# Wait to make sure everything is really gone
	await get_tree().process_frame
	
	# Add new room
	var next_room = new_room_scene.instantiate()
	$GameWorld.add_child(next_room)
