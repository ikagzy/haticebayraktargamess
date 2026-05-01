extends Node

# Oyunun sonlarını kaydedeceği dosya yolu
const SAVE_PATH = "user://valerius_data.cfg"
var config = ConfigFile.new()

# Bitirilen sonları tutan liste
var finished_endings = []

func _ready():
	# Oyun açıldığında daha önce bitirilen sonları yükle
	load_progress()

# Bir son bitirildiğinde bu fonksiyonu çağıracağız
func save_ending(ending_id: String):
	# Eğer bu son daha önce listeye eklenmemişse ekle
	if not ending_id in finished_endings:
		finished_endings.append(ending_id)
		# Dosyaya kaydet
		config.set_value("Progress", "endings", finished_endings)
		config.save(SAVE_PATH)
		print(ending_id, " başarıyla kaydedildi!")

# Kayıtlı verileri dosyadan okuyan fonksiyon
func load_progress():
	var err = config.load(SAVE_PATH)
	if err == OK:
		finished_endings = config.get_value("Progress", "endings", [])
		print("Sonlar yüklendi: ", finished_endings)
