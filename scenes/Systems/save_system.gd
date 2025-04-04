# save_system.gd
extends Node

var save_file_path = "user://savegame.json" # path to the save file

# store game states
var save_data = {
	"current_room": "",
	"inventory": [],
	"room_states": {}
}

# save game state to a file
func save_game():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE) # open file for writing
	if file: #ensures file was opened successfully
		var json_string = JSON.stringify(save_data) # Use JSON.stringify to convert save_data to a JSON string
		file.store_string(json_string) # store JSON string in the file
		print("Game saved successfully")
	else:
		print("Error: Could not open file for saving")

# load game state form a file
func load_game():
	# check if the save file exists
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ) # Open thte file for reading
		if file: # ensure file was opened successfully
			var json_string = file.get_as_text() # readd the file content as text
			var data = JSON.parse_string(json_string) # Use JSON.parse()) to parse the JSON string
			if typeof(data) == TYPE_DICTIONARY: # ensure loaded data is a dictionary
				save_data = data
				print("Game loaded successfully")
				return save_data # return loaded data for use in game logic
			else:
				print("Error: Save data is not valid")
		else:
			print("Error: Could not open file for reading")
	else:
		print("Save file not found")
		return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
