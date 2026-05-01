extends Node

# Mevcut aktif görevin adı
var current_task_text = "Yurttan Çık."
# Görev listesi (ileride buraya yeni görevler ekleyebilirsin)
var tasks = ["Yurttan Çık."] 

signal task_updated # Arayüzü güncellemek için sinyal
