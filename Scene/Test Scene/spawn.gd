class_name SpawnEntity extends Node2D

var enemy_scene:PackedScene = preload("res://Script/Entity/Enemy/Test/enemy_test.tscn")
var player_scene:PackedScene = preload("res://Script/Entity/Player/Arch/arch_player.tscn")


func spawn_player(node, spawn_point:Marker2D):
	var new_player = player_scene.instantiate()
	new_player.name = "MainPlayer"
	node.add_child(new_player)
	
	new_player.global_position = spawn_point.global_position

func spawn_enemy(node, location:Vector2):
	var new_enemy = enemy_scene.instantiate()
	node.add_child(new_enemy)
	new_enemy.global_position = location
	
	return spawn_enemy
