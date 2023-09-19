extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_physics_process(false)
	$Subtitle.visible = false
	$AnimationPlayer.play("anim")
	$Title.visible = false
func _on_animation_player_animation_finished(_anim_name):
	$Subtitle.visible = true
	$DelayInput.start()
	$DashAnimation.play("dash")
	$PressMouse.play("init")
	$Particle/ParticleL.emitting = true
	$Particle/ParticleR.emitting = true
	$Particle/ParticleM.emitting = true

func _on_dash_animation_animation_finished(_anim_name):
	$DashAnimation.play("dash")

func _on_press_mouse_animation_finished(anim_name):
	$PressMouse.play("idle")
	if anim_name == "transition":
		$"../BG".init()
		$"../AnimationPlayer".play("loading1")
		queue_free()

func _physics_process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		set_physics_process(false)
		$PressMouse.play("transition")
		$TransitionSFX.play()

func _on_delay_input_timeout():
	set_physics_process(true)
