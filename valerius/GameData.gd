extends Node

const SAVE_PATH = "user://valerius_data.cfg"
var config = ConfigFile.new()

var finished_endings = []

func _ready():
	load_progress()

func save_ending(ending_id: String):
	if not ending_id in finished_endings:
		finished_endings.append(ending_id)
		config.set_value("Progress", "endings", finished_endings)
		config.save(SAVE_PATH)
		print(ending_id, " başarıyla kaydedildi!")

func load_progress():
	var err = config.load(SAVE_PATH)
	if err == OK:
		finished_endings = config.get_value("Progress", "endings", [])
		print("Sonlar yüklendi: ", finished_endings)
