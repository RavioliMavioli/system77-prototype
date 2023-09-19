extends Node2D

var pause = false

func _ready():
	hide()
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ESC"):
		if !pause:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			pause = true
			show()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			get_tree().paused = false
			pause = false
			hide()

func _on_resume_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	pause = false
	hide()


func _on_quit_menu_pressed():
	SaveLoad.save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Menu/main_menu.tscn")


func _on_retry_pressed():
	get_tree().reload_current_scene()
