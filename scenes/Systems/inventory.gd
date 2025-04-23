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
	
	# Get the slots container
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container:
		print("Warning: SlotsContainer not found")
		return
	
	# Clear all slots first
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
	
	# Create texture for item
	var texture_rect = TextureRect.new()
	
	# Check if icon_path exists
	if "icon_path" in item_data and ResourceLoader.exists(item_data.icon_path):
		texture_rect.texture = load(item_data.icon_path)
	else:
		print("Warning: Item icon not found: ", item_data.get("icon_path", "No path specified"))
		# Use a default texture or placeholder
	
	texture_rect.expand = true
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Add to slot
	slot.add_child(texture_rect)

func clear_slot(slot_index):
	var slots_container = get_node_or_null("Background/Panel/MarginContainer/SlotsContainer")
	if not slots_container or slot_index >= slots_container.get_child_count():
		print("Error: Can't clear slot, slot index out of range or container not found")
		return
	
	var slot = slots_container.get_child(slot_index)
	for child in slot.get_children():
		if child is TextureRect:
			child.queue_free()

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
