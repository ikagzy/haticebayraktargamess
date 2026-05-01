extends Node

# --- REHBER: SİNYALLER ---
signal task_updated(yeni_gorev_metni)

# --- REHBER: DEĞİŞKENLER ---
var current_task_text = "Görev: Masanın Üstünden El Fenerini Al"

# Görevi değiştirmek istediğimizde bu fonksiyonu çağıracağız.
func gorevi_degistir(yeni_yazi):
	current_task_text = yeni_yazi
	# Sinyali yayıyoruz:
	task_updated.emit(current_task_text)
