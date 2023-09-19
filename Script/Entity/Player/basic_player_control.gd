class_name BasicPlayer extends CharacterBody2D

@export var RUNNING_SPEED: float
@export var JUMP_VELOCITY: float
@export var DOUBLE_JUMP_VELOCITY: float

const TERMINAL_VELOCITY: float = 850.0
const TERMINAL_X_VELOCITY: float = 850.0

var character_state:Array = ["idle","run","run_faster","jump","fall", "on_ledge", "hit"]
var character_facing:Array = ["look_forward", "look_backward"]
var character_head:Array = ["straight", "slight_up", "up", "slight_down", "down"]
var character_flip:Array = ["left", "right"]
var character_fire:Array = ["LMB", "RMB", "LMB_RMB", "special_E", "special_Q", "null"]

var current_character_state: int = 0
var current_character_facing: int = 0
var current_character_head: int = 0
var current_character_flip: int = 0
var current_character_fire: int = 0

var character:String
var last_number: Array = [int(0)]
var input_sequence: Array = []

var other_condition_1 = false
var jump_buffer = false
var can_double_jump = true
var can_coyote_jump = true
var can_dash = false
var dashing = false
var is_on_ledge = false
#var is_running = false
var is_on_ledge_L = false
var is_on_ledge_R = false
var coyote_jump_once = true

var RNG_range = 1.0
var SPEED = 1.0

var ledge:Area2D = Area2D.new()
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*1.33

var animation: AnimationPlayer = null
var animation_hitdead: AnimationPlayer = null
var sprite_node: Node2D = null

@onready var collision_on_ground: CollisionShape2D = $CollisionOnGround
@onready var main_collision: CollisionShape2D = $MainCollision
@onready var jump_ground_check: Area2D = $JumpGroundCheck
@onready var ground_check: RayCast2D = $GroundCheck
@onready var ledge_detection_R: CollisionShape2D = $LedgeDetectionR/LedgeDetectionR
@onready var ledge_detection_L: CollisionShape2D = $LedgeDetectionL/LedgeDetectionL
@onready var double_jump_timer: Timer = $Timer/DoubleJump
@onready var coyote_jump_timer: Timer = $Timer/CoyoteJump
@onready var double_tap: Timer = $Timer/DoubleTap
@onready var dash_cooldown: Timer = $Timer/DashCooldown
@onready var dash_duration: Timer = $Timer/DashDuration
@onready var jump_duration: Timer = $Timer/JumpDuration
@onready var ghost_spawn: Timer = $Timer/GhostSpawn
@onready var jump_sound: Array = [get_node("Jump1"),get_node("Jump2"),get_node("Jump3")]
@onready var hit_sfx: AudioStreamPlayer2D = $Hit
@onready var aim_center: Marker2D = $AimCenter
@onready var bullet_spawn: Marker2D = $AimCenter/BulletSpawn


func set_character(character_name:String):
	character = character_name

func initialize():
	sprite_node = get_node(str(character))
	animation = sprite_node.get_node("AnimationPlayer")
	animation_hitdead = sprite_node.get_node("Hitdead")

func spawn():
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO
	get_parent().global_position = Global.player_global_position

func custom_physics_process(delta):
	pass
func _ready():
	set_physics_process(true)

func _physics_process(delta):
	
	#################### GLOBAL VARIABLE $$$$$$$$$$$$$$$$$
	if Global.player_health >= 100:
		Global.player_health = 100
		
	Global.player_current_global_position = global_position
	
	if Global.shoot_L_ammo < 0:
		Global.shoot_L_ammo = 0
	if Global.shoot_L_ammo > Global.max_ammo:
		Global.shoot_L_ammo = Global.max_ammo
		
	if Global.shoot_R_ammo < 0:
		Global.shoot_R_ammo = 0
	if Global.shoot_R_ammo > Global.max_ammo:
		Global.shoot_R_ammo = Global.max_ammo
	
	#################### Y Movement ########################
	
	var global_cursor_position = get_global_mouse_position()
	var global_player_position = self.global_position
	var delta_cursor_position = global_cursor_position - global_player_position
	
	#################### Falling ####################
	
	if !is_on_floor():
		velocity.y += gravity * delta
		collision_on_ground.set_deferred("disabled", true)
		if velocity.y > TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY
		if velocity.y < -TERMINAL_VELOCITY:
			velocity.y = -TERMINAL_VELOCITY
		if can_coyote_jump and coyote_jump_once:
			coyote_jump_once = false
			coyote_jump_timer.start()
	else:
		collision_on_ground.set_deferred("disabled", false)
		if !can_double_jump:
			double_jump_timer.start()
		if !can_coyote_jump:
			can_coyote_jump = true

	#################### Jump ####################	

	if Input.is_action_pressed("ui_accept") and !dashing:
		if is_on_floor():
			jump_duration.start()
			can_coyote_jump = false
			jump_sfx()
		elif Input.is_action_just_pressed("ui_accept") :
			#if !jump_buffer:
			#	jump_ground_check.monitoring = true
			if can_coyote_jump:
				jump_duration.start()
				can_coyote_jump = false
				jump_sfx()
			elif can_double_jump and !is_on_ledge: #and !jump_buffer:
				if !ground_check.is_colliding():
					can_double_jump = false
					double_jump()
				elif ground_check.get_collider().name == "Platform":
					can_double_jump = false
					double_jump()
	#elif jump_buffer and is_on_floor() and !dashing:
	#	jump_ground_check.monitoring = false
	#	jump_buffer = false
	#	jump_duration.start()
	#	can_coyote_jump = false
	#	jump_sfx()				
	
	if Input.is_action_just_released("ui_accept"):
		jump_duration.stop()
	
	jump(jump_duration)
	
	#################### Run Faster ####################
	
	#if Input.is_action_pressed("Shift") and ((delta_cursor_position.x > 0 and velocity.x > 0) or (delta_cursor_position.x < 0 and velocity.x < 0)):
	#	is_running = true
	#	SPEED = lerp(SPEED, RUNNING_SPEED*1.3, 0.25)
	#else:
	#	is_running = false
	#	SPEED = lerp(SPEED, RUNNING_SPEED, 0.25)
	
	
	#################### X Movement ########################
	
	SPEED = lerp(SPEED, RUNNING_SPEED, 0.25)
	
	var direction = Input.get_axis("A", "D")
	if is_on_floor():
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/4)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED/8)
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/16)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED/32)

	if velocity.x > TERMINAL_X_VELOCITY:
		velocity.x = TERMINAL_X_VELOCITY
	if velocity.x < -TERMINAL_X_VELOCITY:
		velocity.x = -TERMINAL_X_VELOCITY
		
	#################### Dash Mechanic ########################

	var just_pressed_A = Input.is_action_just_pressed("A")
	var just_pressed_D = Input.is_action_just_pressed("D")
	
	if xor(just_pressed_A, just_pressed_D):
		input_sequence.append(direction)
	
	if Global.obtained_dash:
		if double_tap.time_left > 0.1:
			if is_on_floor() or (!is_on_floor() and !ground_check.is_colliding()):
				if input_sequence.size() == 2 and !can_dash:
					if input_sequence[0] == input_sequence[1] and input_sequence[0] != 0:
						can_dash = true
						dashing = true
						dash_cooldown.start()
						dash_duration.start()
						ghost_spawn.start()
				
	if just_pressed_A or just_pressed_D:
		double_tap.start()
		
	if input_sequence.size() >= 2:
		input_sequence[0] = input_sequence.back()
		input_sequence.resize(1)

		
	if dashing:
		velocity.x = move_toward(velocity.x, input_sequence.back() * RUNNING_SPEED * 4, RUNNING_SPEED)
		velocity.y = 0
	
	if is_on_wall():
		dashing = false
	
	#################### Ledge Hanging Mechanic ########################
	
	var vertical_velocity_tolerance = -350.0
	
	if is_on_ledge and !ground_check.is_colliding() and velocity.y > vertical_velocity_tolerance:
		can_double_jump = true
		if Input.is_action_just_pressed("S"):
			is_on_ledge = false
		if Input.is_action_just_pressed("ui_accept"):
			is_on_ledge = false
			jump_duration.start()
			jump(jump_duration)
			jump_sfx()
		else:
			velocity.y = 0
			velocity.x = 0
			if is_on_ledge_L:
				global_position = lerp(global_position, ledge.global_position - ledge_detection_L.position, 0.5)
			elif is_on_ledge_R:
				global_position = lerp(global_position, ledge.global_position - ledge_detection_R.position, 0.5)
	else:
		is_on_ledge = false
		
	#################### Shooting Mechanic ########################
	
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		shoot_lmb()
	
	#################### Platfform ########################
	
	if ground_check.is_colliding() and ground_check.get_collider().name == "Platform":
		if Input.is_action_pressed("S"):
			main_collision.set_deferred("disabled", true)
			collision_on_ground.set_deferred("disabled", true)
		
	else:
		main_collision.set_deferred("disabled", false)
		
	#################### Specials ########################
	
	if Input.is_action_just_pressed("E"):
		special_e()
	
	if Input.is_action_just_pressed("Q"):
		special_q()
	
	#################### Character State ########################
	
	#################### State ########################
	
	if is_on_floor():
		if velocity.x != 0:
			current_character_state = character_state.find("run")
			#if is_running:
			#	current_character_state = character_state.find("run_faster")
		else:
			current_character_state = character_state.find("idle")
	
	else:
		if velocity.y > 0:
			current_character_state = character_state.find("fall")
		else:
			current_character_state = character_state.find("jump")
	
	if is_on_ledge:
		current_character_state = character_state.find("on_ledge")
		
	#################### Facing ########################
	
	if direction != 0:
		if direction > 0:
			if delta_cursor_position.x > 0:
				current_character_facing = character_facing.find("look_forward")
			else:
				current_character_facing = character_facing.find("look_backward")
		else:
			if delta_cursor_position.x < 0:
				current_character_facing = character_facing.find("look_forward")
			else:
				current_character_facing = character_facing.find("look_backward")
	else:
		if is_on_floor():
			current_character_facing = character_facing.find("look_forward")

	if current_character_state == character_state.find("on_ledge"):	
		if is_on_ledge_R:
			if delta_cursor_position.x > 0:
				current_character_facing = character_facing.find("look_forward")
			else:
				current_character_facing = character_facing.find("look_backward")
		elif is_on_ledge_L:
			if delta_cursor_position.x < 0:
				current_character_facing = character_facing.find("look_forward")
			else:
				current_character_facing = character_facing.find("look_backward")
	
	#################### Head ########################
	
	var head_angle = abs(delta_cursor_position.normalized()).angle()
	var head_angle_degrees = rad_to_deg(head_angle)
	
	if delta_cursor_position.y <= 0:
		if head_angle_degrees <= 20.0:
			current_character_head = character_head.find("straight")
		elif head_angle_degrees <= 60.0:
			current_character_head = character_head.find("slight_up")
		elif head_angle_degrees <= 90.0:
			current_character_head = character_head.find("up")
	else:
		if head_angle_degrees <= 20.0:
			current_character_head = character_head.find("straight")
		elif head_angle_degrees <= 60.0:
			current_character_head = character_head.find("slight_down")
		elif head_angle_degrees <= 90.0:
			current_character_head = character_head.find("down")
	
	#################### Flip ########################
	
	if delta_cursor_position.x >= 0:
		current_character_flip = character_flip.find("right")
	else:
		current_character_flip = character_flip.find("left")
	
	if current_character_state == character_state.find("on_ledge"):
		if is_on_ledge_L:
			current_character_flip = character_flip.find("left")
		elif is_on_ledge_R:
			current_character_flip = character_flip.find("right")
	
	#################### Fire ########################
	
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		current_character_fire = character_fire.find("LMB_RMB")
		
	elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		current_character_fire = character_fire.find("LMB")
	
	elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		current_character_fire = character_fire.find("RMB")
	
	elif Input.is_action_just_pressed("E"):
		current_character_fire = character_fire.find("special_E")
	
	elif Input.is_action_just_pressed("Q"):
		current_character_fire = character_fire.find("special_Q")
	
	else:
		current_character_fire = character_fire.find("null")
	
	#################### Animation ########################
	
	#################### Facing ########################
	
	if current_character_flip == character_flip.find("right"):
		sprite_node.scale.x = 1
	elif current_character_flip == character_flip.find("left"):
		sprite_node.scale.x = -1
	
	var anim_speed:float = 1.3
	
	match character_state[current_character_state]:
		"idle":
			match character_facing[current_character_facing]:
				"look_forward":
					match character_fire[current_character_fire]:
						"null":
							match character_head[current_character_head]:
								"straight":
									animation.play("idle_forward_noshoot_0")
								"slight_up":
									animation.play("idle_forward_noshoot_45")
								"up":
									animation.play("idle_forward_noshoot_90")
								"slight_down":
									animation.play("idle_forward_noshoot_-45")
								"down":
									animation.play("idle_forward_noshoot_-90")
						_:
							match character_head[current_character_head]:
								"straight":
									animation.play("idle_forward_shoot_0")
								"slight_up":
									animation.play("idle_forward_shoot_45")
								"up":
									animation.play("idle_forward_shoot_90")
								"slight_down":
									animation.play("idle_forward_shoot_-45")
								"down":
									animation.play("idle_forward_shoot_-90")

		"run":
			match character_facing[current_character_facing]:
				"look_forward":
					match character_fire[current_character_fire]:
						"null":
							match character_head[current_character_head]:
								"straight":
									animation.play("run_forward_noshoot_0", -1, anim_speed)
								"slight_up":
									animation.play("run_forward_noshoot_45", -1, anim_speed)
								"up":
									animation.play("run_forward_noshoot_90", -1, anim_speed)
								"slight_down":
									animation.play("run_forward_noshoot_-45", -1, anim_speed)
								"down":
									animation.play("run_forward_noshoot_-90", -1, anim_speed)
						_:
							match character_head[current_character_head]:
								"straight":
									animation.play("run_forward_shoot_0", -1, anim_speed)
								"slight_up":
									animation.play("run_forward_shoot_45", -1, anim_speed)
								"up":
									animation.play("run_forward_shoot_90", -1, anim_speed)
								"slight_down":
									animation.play("run_forward_shoot_-45", -1, anim_speed)
								"down":
									animation.play("run_forward_shoot_-90", -1, anim_speed)
				"look_backward":
					match character_fire[current_character_fire]:
						"null":
							match character_head[current_character_head]:
								"straight":
									animation.play("run_backward_noshoot_0", -1, anim_speed)
								"slight_up":
									animation.play("run_backward_noshoot_45", -1, anim_speed)
								"up":
									animation.play("run_backward_noshoot_90", -1, anim_speed)
								"slight_down":
									animation.play("run_backward_noshoot_-45", -1, anim_speed)
								"down":
									animation.play("run_backward_noshoot_-90", -1, anim_speed)
						_:
							match character_head[current_character_head]:
								"straight":
									animation.play("run_backward_shoot_0", -1, anim_speed)
								"slight_up":
									animation.play("run_backward_shoot_45", -1, anim_speed)
								"up":
									animation.play("run_backward_shoot_90", -1, anim_speed)
								"slight_down":
									animation.play("run_backward_shoot_-45", -1, anim_speed)
								"down":
									animation.play("run_backward_shoot_-90", -1, anim_speed)
		"jump":
			animation.play("jump")
		"fall":
			animation.play("fall")
		"on_ledge":
			animation.play("edge")
			
	if $Timer/Hit.time_left > 0.1:
		animation_hitdead.play("hit")
		
	if Global.player_health <= 0:
		animation_hitdead.play("dead")
		set_physics_process(false)
	
		
	#################### Custom physic process on inheritance ########################
	custom_physics_process(delta)
	
	#################### move_and_slide ########################
	
	move_and_slide()
	
	#################### Label print ########################
	
	$Label/CharState.text = character_state[current_character_state]
	$Label/CharFacing.text = character_facing[current_character_facing]
	$Label/CharHead.text = character_head[current_character_head]
	$Label/CharFlip.text = character_flip[current_character_flip]
	$Label/CharFire.text = character_fire[current_character_fire]

#################### Ledge Mechanic Signal ########################

func _on_ledge_detection_l_area_entered(area):
	if "Edge" in area.name:
		ledge = area
		is_on_ledge = true
		is_on_ledge_L = true
		
func _on_ledge_detection_l_area_exited(_area):
	ledge = null
	is_on_ledge = false
	is_on_ledge_L = false

func _on_ledge_detection_r_area_entered(area):
	if "Edge" in area.name:
		ledge = area
		is_on_ledge = true
		is_on_ledge_R = true

func _on_ledge_detection_r_area_exited(_area):
	ledge = null
	is_on_ledge = false
	is_on_ledge_R = false
	
#################### Jump ########################
	
func jump(jump_dur: Timer):
	var time_left = jump_dur.time_left
	if time_left > 0:
		velocity.y = -JUMP_VELOCITY - (time_left/jump_duration.wait_time*100)

func jump_sfx():
	jump_sound[rng_norepeat(1,2)].play()
	
func double_jump():
	if Global.obtained_double_jump:
		velocity.y = -DOUBLE_JUMP_VELOCITY
		jump_sound[0].play()

#################### Specials ########################

func shoot_lmb():
	pass
	
func shoot_rmb():
	pass

func special_e():
	pass
	
func special_q():
	pass

func xor(a, b):
	if a == b:
		return false
	elif a or b:
		return true
		
#################### Dead ########################
func get_shot(bullet_position:Vector2, damage:int):
	Global.player_health -= damage
	#$Hitbox/CollisionShape2D.disabled = true
	$Timer/Hit.start()
	hit_sfx.play()
	
func pit():
	spawn()
#################### Etc ########################
func RNG():
	if RNG_range > 5.0:
		RNG_range = 5
	var rng1 = randf_range(RNG_range, -RNG_range)
	return rng1
	
func rng(range1, range2):
	var rng2 = randf_range(range1, range2)
	return rng2
func rng_int(range1, range2):
	var rng3: int = randi_range(range1, range2)
	return rng3

func rng_norepeat(range1, range2):
	var t = last_number[last_number.size()-1]
	var rng4 = randi_range(range1, range2)
	while rng4 == t:
		rng4 = randi_range(range1, range2)
	last_number[last_number.size()-1] = rng4
	return rng4

func _on_double_jump_timeout():
	can_double_jump = true

func _on_coyote_jump_timeout():
	coyote_jump_once = true
	can_coyote_jump = false

func _on_dash_cooldown_timeout():
	can_dash = false

func _on_dash_duration_timeout():
	ghost_spawn.stop()
	dashing = false
	velocity.x = 0

func _on_up_check_body_entered(body):
	if body.name == "Wall":
		jump_duration.stop()

func _on_jump_ground_check_body_entered(body):
	if body.name == "Wall":
		jump_buffer = true


func _on_ghost_spawn_timeout():
	var new_sprite: Node2D = sprite_node.duplicate()
	var new_tween:Tween = create_tween()
	
	new_sprite.modulate =  Color(3, 3, 3)
	
	new_tween.tween_property(new_sprite, "modulate:a", 0.0, 0.3)
	new_tween.finished.connect(Callable(ghost_tween_complete).bind(new_sprite))
	get_tree().get_current_scene().add_child(new_sprite)
	new_sprite.global_position = global_position


func ghost_tween_complete(new_sprite):
	new_sprite.queue_free()


func _on_hit_timeout():
	#$Hitbox/CollisionShape2D.disabled = false
	pass
	
