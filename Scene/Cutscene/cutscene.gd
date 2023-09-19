extends Control

func _ready():
	$AnimationPlayer.play("init")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"end":
			get_tree().change_scene_to_file("res://Scene/Level 1/level1.tscn")
		"init":
			$AnimationPlayer.play("end")
