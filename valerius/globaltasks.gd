extends Node

signal task_updated(yeni_gorev_metni)

var current_task_text = "Görev: Masanın Üstünden El Fenerini Al"

func gorevi_degistir(yeni_yazi):
	current_task_text = yeni_yazi
	task_updated.emit(current_task_text)
