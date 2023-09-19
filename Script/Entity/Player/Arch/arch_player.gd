extends BasicPlayer
@export var HOOK_MAX_LENGTH: float
@export var HOOK_VELOCITY: float
@export var HOOK_PULL: float
@export var RMB_BULLET_AMMOUNT_PER_TARGET: int

var lock_system: PackedScene = preload("res://Script/Entity/Player/Arch/Locking System/lock.tscn")

@onready var shoot_l = ArchShoot.new(self, $AimCenter, $AimCenter/BulletSpawn)
@onready var shoot_r = ArchShoot.new(self, $AimCenter, $AimCenter/BulletSpawn)
@onready var hook_aim: Node2D = $HookAim
@onready var hook_destination: Marker2D = $HookAim/HookDestination
@onready var hook_node: Node2D = $hook2

var shooting_rmb = false
var hook_buffer = false
var hook_velocity: Vector2 
var current_bullet_target: int = 0


func _ready():
	hook_destination.position.x += HOOK_MAX_LENGTH
	character_state.append("hooked")
	set_character(Global.characters[Global.current_character])
	initialize()
	
	shoot_l.set_projectile("res://Script/Bullet/Arch/Bullet1/arch_bullet_1.tscn")
	#shoot_l.set_post_shoot("res://Script/Bullet/bullet_case.tscn")
	shoot_l.set_sfx("res://Script/Bullet/Arch/Bullet1/arch_bullet_1_sfx.tscn")
	
	shoot_r.set_projectile("res://Script/Bullet/Arch/Bullet2/arch_bullet_2.tscn")
	#shoot_r.set_post_shoot("res://Script/Bullet/bullet_case.tscn")
	shoot_r.set_sfx("res://Script/Bullet/Arch/Bullet2/arch_bullet_2_sfx.tscn")

func custom_physics_process(delta):
	
	hook_aim.look_at(get_global_mouse_position())
	
	
	if hook_node.hooked:
		current_character_state = character_state.find("hooked")
		velocity.x = move_toward(velocity.x, 0, SPEED/32)
		
		can_double_jump = false
		ledge_detection_R.disabled = true
		ledge_detection_L.disabled = true
		if Input.is_action_just_pressed("ui_accept"):
			
			hook_node.retract()
			
			if hook_node.tip.global_position.y < global_position.y:
				double_jump_timer.start()
				velocity.y += -JUMP_VELOCITY
				jump_sfx()
		
		hook_velocity = to_local(hook_node.tip_position).normalized() * HOOK_PULL
		
		#if hook_velocity.y > 0:
			# Pulling down isn't as strong
			#hook_velocity.y *= 0.5
		#else:
			# Pulling up is stronger
			#hook_velocity.y *= 0.5
		#if delta_tip_position.length() > 200:
		hook_velocity = hook_node.delta_tip_position/100 * HOOK_PULL
		
		
		if Input.get_axis("W", "S"):
			hook_velocity.y *= 0.7*Input.get_axis("W", "S")
			
		#if hook_node.delta_tip_position.length() < 50:
		#	hook_velocity = Vector2(0,0)
			
		#if hook_node.deltwa_tip_position.length() < 150:
		#	hook_velocity /= 100
	else:
		ledge_detection_R.disabled = false
		ledge_detection_L.disabled = false
		hook_velocity = Vector2(0,0)
	
	if hook_buffer and !hook_node.flying:
		hook_buffer = false
		hook()
	
	velocity += hook_velocity
	
	if Input.is_action_just_pressed("RMB") and Global.shoot_R_ammo < 90:
		$SFXRMB1.play()
		Global.current_locked = 0
		Global.lock_queue.clear()
		Global.local_target_querry.clear()
		$"../Cursor/Scan".monitoring = true
	
	if Input.is_action_just_released("RMB") and Global.shoot_R_ammo < 90:
		$SFXRMB2.play()
		$"../Cursor/Scan".monitoring = false
		Global.current_locked = 0
		shoot_rmb()

func shoot_lmb():
	shoot_l.initialize_for_player()
	if shoot_l.shoot_1():
		$"../Cursor".shoot_lmb()

func shoot_rmb():
	current_bullet_target = 0
	$RMBShoot.start()

func special_e():
	if Global.obtained_hook:
		if hook_node.flying and hook_node.delta_tip_position.length() < 200:
			hook_buffer = true
		hook()
	
func hook():
	var delta = hook_destination.global_position - hook_aim.global_position
	
	if !hook_node.flying and !hook_node.hooked:
		hook_node.shoot(delta, hook_aim, HOOK_VELOCITY, HOOK_MAX_LENGTH)
	if hook_node.hooked:
		hook_node.retract()


func _on_scan_body_entered(body):
	if ("Boss" in body.name and Global.local_target_querry.size() < Global.max_lock) or (!(body in Global.lock_queue) and !(body in Global.local_target_querry) and Global.local_target_querry.size() < Global.max_lock):
		var new_lock = lock_system.instantiate()
		new_lock.target = body
		Global.local_target_querry.push_back(body)
		get_tree().get_current_scene().call_deferred("add_child", new_lock)
		Global.current_locked += 1
		
		$"../Cursor".target_found()
		

func _on_rmb_shoot_timeout():
	shooting_rmb = true
	
	if Global.shoot_R_ammo < Global.max_ammo:
		if current_bullet_target < RMB_BULLET_AMMOUNT_PER_TARGET:
			if Global.current_locked < Global.lock_queue.size():
				var current_target = Global.lock_queue[Global.current_locked]
				if Global.lock_queue[Global.current_locked] != null and !Global.lock_queue[Global.current_locked].is_dead():
					shoot_r.initialize_for_player()
					shoot_r.shoot_homing_missile(current_target)
					Global.current_locked += 1
					Global.shoot_R_ammo += 1
	
			else:
				Global.current_locked = 0
				current_bullet_target += 1

	else:
		shooting_rmb = false
		current_bullet_target = 0
		$RMBShoot.stop()
