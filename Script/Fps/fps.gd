extends Label

func _process(_delta):
	if Global.show_fps:
		var fps = Engine.get_frames_per_second()
		text = "FPS: "+str(fps)
	else:
		text = ""
