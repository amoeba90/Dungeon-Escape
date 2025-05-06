# inventory_utils.gd
extends Node

# Check if player has an item with a specific id or containing a specific string
func has_item(item_id_contains: String) -> bool:
	if "inventory" in SaveSystem.save_data:
		var inventory = SaveSystem.save_data["inventory"]
		
		# Loop through inventory items
		for item in inventory:
			# Check if item is a dictionary with matching id
			if typeof(item) == TYPE_DICTIONARY and "id" in item and item_id_contains in item["id"]:
				print("Found item in inventory: ", item["id"])
				return true
	
	print("No item containing '", item_id_contains, "' found in inventory")
	return false

# Check if player has an item with an exact id
func has_exact_item(exact_id: String) -> bool:
	if "inventory" in SaveSystem.save_data:
		var inventory = SaveSystem.save_data["inventory"]
		
		# Loop through inventory items
		for item in inventory:
			# Check if item is a dictionary with matching id
			if typeof(item) == TYPE_DICTIONARY and "id" in item and item["id"] == exact_id:
				print("Found exact item in inventory: ", item["id"])
				return true
	
	print("No item with exact id '", exact_id, "' found in inventory")
	return false

# Remove an item with an id containing a specific string
func remove_item(item_id_contains: String) -> bool:
	if "inventory" in SaveSystem.save_data:
		var inventory = SaveSystem.save_data["inventory"]
		var item_index = -1
		
		# Find the item's index
		for i in range(inventory.size()):
			var item = inventory[i]
			if typeof(item) == TYPE_DICTIONARY and "id" in item and item_id_contains in item["id"]:
				item_index = i
				break
		
		# Remove the item if found
		if item_index >= 0:
			inventory.remove_at(item_index)
			SaveSystem.save_data["inventory"] = inventory
			SaveSystem.save_game()
			print("Item removed from inventory: ", item_id_contains)
			return true
	
	print("Failed to remove item: ", item_id_contains)
	return false

# Remove an item with an exact id
func remove_exact_item(exact_id: String) -> bool:
	if "inventory" in SaveSystem.save_data:
		var inventory = SaveSystem.save_data["inventory"]
		var item_index = -1
		
		# Find the item's index
		for i in range(inventory.size()):
			var item = inventory[i]
			if typeof(item) == TYPE_DICTIONARY and "id" in item and item["id"] == exact_id:
				item_index = i
				break
		
		# Remove the item if found
		if item_index >= 0:
			inventory.remove_at(item_index)
			SaveSystem.save_data["inventory"] = inventory
			SaveSystem.save_game()
			print("Item removed from inventory: ", exact_id)
			return true
	
	print("Failed to remove item: ", exact_id)
	return false

# Get an item from inventory by id contains
func get_item(item_id_contains: String) -> Dictionary:
	if "inventory" in SaveSystem.save_data:
		var inventory = SaveSystem.save_data["inventory"]
		
		# Loop through inventory items
		for item in inventory:
			# Check if item is a dictionary with matching id
			if typeof(item) == TYPE_DICTIONARY and "id" in item and item_id_contains in item["id"]:
				return item
	
	return {}
