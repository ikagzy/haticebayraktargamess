extends AudioStreamPlayer

func _ready():
	if stream is AudioStreamMP3:
		stream.loop = true
	
	
	play()
