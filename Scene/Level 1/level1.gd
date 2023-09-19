extends Node2D
var enemies: Array
var enemy = preload("res://Script/Entity/Enemy/Enemy 1/enemy1.tscn")
var ded = false
func _ready():
	Global.player_health = 100
	Global.score = 0
	ded = false
	SaveLoad.load_data()
	$MainPlayer.global_position = Global.player_global_position
	# Changes a specific shape of the cursor (here, the I-beam shape).
	#Input.set_custom_mouse_cursor(null)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Global.continuable = 0
	SaveLoad.save_data()
	Global.max_lock = 5
	Global.just_started = 0
	Global.obtained_double_jump = 1
	Global.obtained_dash = 1
	Global.obtained_hook = 1
	Global.obtained_specials = 0

func _physics_process(delta):
	if Global.player_health <= 0 and !ded:
		ded = true
		$Start.play("game_over")
	

func _on_save_state_timeout():
	if $MainPlayer.get_node("Player").is_on_floor():
		Global.player_global_position = $MainPlayer.get_node("Player").global_position
	SaveLoad.save_data()


func _on_timer_timeout():
	if enemies.size() < 100:
		var RNG = randf_range(-1000,1000)
		var new_enemy = enemy.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = global_position + Vector2(RNG,200)
		enemies.append(new_enemy)
		for i in enemies:
			if !is_instance_valid(i):
				enemies.erase(i)

func _on_pit_body_entered(body):
	if body.has_method("pit"):
		body.pit()


func _on_start_animation_finished(anim_name):
	if anim_name == "game_over":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	


func _on_start_2_timeout():
	$Timer.start()


func _on_wait_time_timeout():
	if $Timer.wait_time > 0.5:
		$Timer.wait_time -= 0.1
