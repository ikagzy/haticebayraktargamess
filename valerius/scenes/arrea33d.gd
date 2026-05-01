extends Area3D

func _on_body_entered(body):
	# Karakterin (CharacterBo) bu alana girdiğinden emin oluyoruz
	if body.name == "CharacterBo":
		# gorevsistemi sahnen World içinde bir çocuksa ona ulaşıyoruz
		# Not: Yol senin sahne yapına göre "$../gorevsistemi" gibi değişebilir
		var sistem = get_tree().root.find_child("gorevsistemi", true, false)
		
		if sistem:
			sistem.gorev_tamamla()
			# Görev bir kere tamamlanınca bu alanı yok et ki sürekli tetiklenmesin
			queue_free()
