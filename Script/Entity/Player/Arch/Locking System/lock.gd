extends Node2D

var target: Object
var locked = false

func _ready():
	$Circle.hide() 
	$Lock.hide()

func _physics_process(delta):
	if !Input.is_action_pressed("RMB"):
		$AnimationPlayer.play("cancel")
	if locked:
		if target != null:
			#global_position = lerp(global_position, target.global_position, delta*10)
			global_position = target.global_position
			if target.has_method("is_dead") and target.is_dead():
				$AnimationPlayer.play("cancel")
	else:
		global_position = get_global_mouse_position()

func _on_scan_body_entered(body):
	if not locked:
		$SFXInit.play()
		$AnimationPlayer.play("locking")
		locked = true
		#target = body #Body is passed via player script

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"cancel":
			$Scan.monitoring = false
			queue_free()
		"locking":
			Global.lock_queue.push_front(target)
			$AnimationPlayer.play("target_found")
			$SFXLocked.play()
		"target_found":
			$AnimationPlayer.play("locked")
		"locked":
			$AnimationPlayer.play("locked")
	
