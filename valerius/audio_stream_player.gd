extends AudioStreamPlayer

func _ready():
	# Eğer dosyan MP3 ise:
	if stream is AudioStreamMP3:
		stream.loop = true
	
	# Eğer dosyan OGG ise (MP3 değilse bunu açabilirsin):
	# if stream is AudioStreamOggVorbis:
	# 	stream.loop = true
	
	play()
