extends Node2D

@onready var init_scale:Vector2 = $Crosshair.scale

func _ready():
	$Target.hide()
	$Cross.hide()
func _physics_process(delta):
	global_position = get_global_mouse_position()
	
	$Crosshair.scale = lerp($Crosshair.scale, init_scale, delta*2)
	
	if Input.is_action_just_pressed("RMB") and Global.shoot_R_ammo < 90:
		$AnimationPlayer.play("init")
	if Input.is_action_just_released("RMB") and Global.shoot_R_ammo < 90:
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play_backwards("init")

	$Cross/Label.text = str(Global.lock_queue.size())

func shoot_lmb():
	$Crosshair.scale += Vector2(0.05,0.05)
	if $Crosshair.scale.x >= 0.4:
		$Crosshair.scale = Vector2(0.4,0.4)

func target_found():
	pass
	#$AnimationPlayer.stop(true)
	#$AnimationPlayer.play("lock_found")
