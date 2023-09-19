extends Control


func _ready():
	Global.fullscreen = 1
	SaveLoad.load_data()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("bootanim")
	if Global.fullscreen == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Scene/Menu/main_menu.tscn")
