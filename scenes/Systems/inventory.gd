# inventory.gd
extends Node2D

signal inventory_closed

# Position constants
const OFF_SCREEN_POS = Vector2(2100, 540)  # Matching your main script
const ON_SCREEN_POS = Vector2(1725, 540)    # Center of 1920x1080 screen

# State variables
var is_visible = false
var selected_item_index = -1

func _ready():
	# Set initial position and visibility
	position = OFF_SCREEN_POS
	visible = false
	is_visible = false
	
	# Connect interactive areas with proper error handling
	var areas_node = get_node_or_null("InteractiveAreas")
	if areas_node:
		for i in range(1, 11):  # For slots 1-10
			var area_name = "Slot" + str(i) + "_Area"
			var area_node = areas_node.get_node_or_null(area_name)
			if area_node:
				area_node.connect("input_event", _on_slot_input.bind(i-1))
			else:
				print("Warning: Area node not found: ", area_name)
	
	# Load inventory items
	load_inventory()

func load_inventory():
	# Get inventory from SaveSystem
	var items = SaveSystem.save_data.get("inventory", [])
	print("Loading inventory with items: ", items)
	
	# Get the slots container
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container:
		print("Warning: SlotsContainer not found")
		return
	
	# Clear ALL slots first
	print("Clearing all slots")
	for i in range(slots_container.get_child_count()):
		clear_slot(i)
	
	# Display items in slots
	for i in range(min(items.size(), slots_container.get_child_count())):
		display_item(i, items[i])


func display_item(slot_index, item_data):
	# Get the slots container
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container or slot_index >= slots_container.get_child_count():
		print("Error: Can't display item, slot index out of range or container not found")
		return
	
	# Get the slot
	var slot = slots_container.get_child(slot_index)
	
	# Clear any existing item texture
	clear_slot(slot_index)
	
	# Convert string items to dictionary format if needed
	if typeof(item_data) == TYPE_STRING:
		var item_name = item_data.capitalize()
		item_data = {
			"id": item_data,
			"name": item_name,
			"description": "A " + item_data,
			"icon_path": "res://assets/Sprites/Inventory/" + item_data + ".png"
		}
	
	# Create center container to properly center the icon
	var center_container = CenterContainer.new()
	center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Make center container take up the full slot
	center_container.custom_minimum_size = Vector2(150, 150)
	
	# Create texture rect with proper sizing
	var texture_rect = TextureRect.new()
	
	# Try to load the icon
	if item_data.has("icon_path") and ResourceLoader.exists(item_data.icon_path):
		texture_rect.texture = load(item_data.icon_path)
	else:
		print("Warning: Icon not found at: " + item_data.get("icon_path", "unknown path"))
		# Create a placeholder if needed
	
	# Set up TextureRect to fit within the slot properly
	texture_rect.expand = true
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Make the texture rect slightly smaller than the slot for padding
	texture_rect.custom_minimum_size = Vector2(130, 130)
	
	# Add texture_rect to the center container
	center_container.add_child(texture_rect)
	
	# Add the center container to the slot
	slot.add_child(center_container)
	
	# Play item appear sound
	AudioManager.play_sfx("res://assets/Audio/SFX/item-pickup.mp3")

func clear_slot(slot_index):
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container or slot_index >= slots_container.get_child_count():
		print("Error: Can't clear slot, slot index out of range or container not found")
		return
	
	var slot = slots_container.get_child(slot_index)
	
	# Remove ALL children from the slot, not just TextureRects
	for child in slot.get_children():
		child.queue_free()
	
	# Force slot update
	slot.queue_redraw()
	
	print("Slot " + str(slot_index) + " cleared")

func toggle_visibility():
	is_visible = !is_visible
	
	if is_visible:
		# Make visible first, then animate
		visible = true
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", ON_SCREEN_POS, 0.3)
	else:
		# Animate, then hide when done
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", OFF_SCREEN_POS, 0.3)
		tween.tween_callback(func(): visible = false)
		
		# Reset any selected item when closing
		if selected_item_index >= 0:
			deselect_item()
		
		# Emit closed signal
		emit_signal("inventory_closed")

func _on_slot_input(viewport, event, shape_idx, slot_index):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var items = SaveSystem.save_data.get("inventory", [])
		
		# Check if there's an item in this slot
		if slot_index < items.size():
			# If same slot selected, deselect
			if slot_index == selected_item_index:
				deselect_item()
			else:
				select_item(slot_index)

func select_item(slot_index):
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container:
		print("Error: Can't select item, container not found")
		return
	
	# Deselect previous item if any
	if selected_item_index >= 0 and selected_item_index < slots_container.get_child_count():
		# Remove highlight from previous selection
		var prev_slot = slots_container.get_child(selected_item_index)
		prev_slot.modulate = Color(1, 1, 1, 1)
	
	# Set new selection
	selected_item_index = slot_index
	
	# Highlight selected slot
	if slot_index < slots_container.get_child_count():
		var slot = slots_container.get_child(slot_index)
		slot.modulate = Color(1.2, 1.2, 0.8, 1)  # Slight highlight
	
	# Get item data
	var items = SaveSystem.save_data.get("inventory", [])
	if slot_index < items.size():
		var item_data = items[slot_index]
		
		# Change cursor to item (if you have an icon path)
		if "icon_path" in item_data and ResourceLoader.exists(item_data.icon_path):
			Input.set_custom_mouse_cursor(load(item_data.icon_path))
		
		# Make inventory semi-transparent
		modulate.a = 0.7
		
		# Set active item in Main
		var main = get_node("/root/Main")
		if main:
			main.active_item_data = item_data

func deselect_item():
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container:
		print("Error: Can't deselect item, container not found")
		return
	
	if selected_item_index >= 0 and selected_item_index < slots_container.get_child_count():
		# Remove highlight
		var slot = slots_container.get_child(selected_item_index)
		slot.modulate = Color(1, 1, 1, 1)
	
	# Reset selection
	selected_item_index = -1
	
	# Reset cursor
	Input.set_custom_mouse_cursor(null)
	
	# Restore opacity
	modulate.a = 1.0
	
	# Clear active item in Main
	var main = get_node("/root/Main")
	if main:
		main.active_item_data = null

func use_selected_item():
	if selected_item_index >= 0:
		# Remove item from inventory
		var items = SaveSystem.save_data.get("inventory", [])
		if selected_item_index < items.size():
			items.remove_at(selected_item_index)
			SaveSystem.save_data["inventory"] = items
			SaveSystem.save_game()
		
		# Reset selection
		deselect_item()
		
		# Reload inventory
		load_inventory()
