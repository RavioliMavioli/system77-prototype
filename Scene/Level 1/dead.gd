extends Node2D

var pause = false

func _ready():
	hide()

func _on_quit_menu_pressed():
	SaveLoad.save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Menu/main_menu.tscn")


func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
