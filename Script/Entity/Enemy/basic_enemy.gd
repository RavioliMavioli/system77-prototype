class_name Enemy extends CharacterBody2D

@export var KNOCKBACK_FACTOR:int
@export var HEALTH:float

const TERMINAL_VELOCITY: float = 850.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*1.33

@onready var health_label:RichTextLabel = $HealthBar/ControlHealthLabel/HealthLabel
@onready var health_bar:TextureProgressBar = $HealthBar/ControlHealthBar/HealthBar
@onready var parent:Node2D = $HealthBar
@onready var boom:AnimatedSprite2D = $Boom
@onready var dead_sfx:AudioStreamPlayer2D = $DeadSFX
@onready var sprite:AnimatedSprite2D = $Sprite
@onready var hitbox:CollisionShape2D = $CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var camera_shake: ScreenShake = ScreenShake.new(get_tree().current_scene.get_node("Camera2D"))

var state = ["idle", "walk", "fly", "jump", "attack", "shoot", "dead"]
var current_state: int

var ammo_drop:PackedScene = preload("res://Script/Dropable/Ammo/ammo_drop.tscn")
var secondary_drop:PackedScene = preload("res://Script/Dropable/Secondary Ammo/secondary_drop.tscn")
var health_drop:PackedScene = preload("res://Script/Dropable/Health/health_drop.tscn")

var global_player_position: Vector2
var delta_player_position: Vector2

var current_health:float
var rip = false

func custom_ready():
	pass

func enemy_behaviour(delta):
	pass

func custom_hit():
	pass

func custom_death():
	pass

func _ready():
	spawn()
	parent.hide()
	sprite.visible = true
	boom.visible = false
	custom_ready()
	current_health = HEALTH

func _physics_process(delta):
	
	############## HEALTH BAR ##############
	
	parent.global_position = global_position
	parent.global_rotation = 0.0
	
	############## BEHAVIOUR ##############
	
	global_player_position = Global.player_current_global_position
	delta_player_position = global_player_position - global_position
	
	#################### Y Movement ########################
	
	#################### Falling ####################
	
	if motion_mode == CharacterBody2D.MOTION_MODE_GROUNDED:
		if !is_on_floor():
			velocity.y += gravity * delta
			if velocity.y > TERMINAL_VELOCITY:
				velocity.y = TERMINAL_VELOCITY
			if velocity.y < -TERMINAL_VELOCITY:
				velocity.y = -TERMINAL_VELOCITY
		
	#################### X Movement ########################
	
	enemy_behaviour(delta)
	
	if motion_mode != CharacterBody2D.MOTION_MODE_GROUNDED:
		velocity.y = lerp(velocity.y, 0.0, delta*10)
	velocity.x = lerp(velocity.x, 0.0, delta*10)
	
	#################### STATE ########################
	
#	if motion_mode == CharacterBody2D.MOTION_MODE_GROUNDED:
#		if velocity.y < 0:
#			current_state = state.find("jump")
#		else:
#			current_state = state.find("fall")
#
#		if velocity.x == 0:
#			current_state = state.find("idle")
#		else:
#			current_state = state.find("walk")
#	else:
#		current_state = state.find("fly")
	
	####################
	move_and_slide()
	####################
func get_shot(bullet_position:Vector2, damage:int):
	$HitSFX.play()
	anim.stop(true)
	anim.play("hit")
		
	camera_shake.screen_shake_short_weak()
	
	var knockback:Vector2# = global_position - bullet_position
	var knockback_direction = delta_player_position.x
	
	if knockback_direction >= 0:
		
		knockback = Vector2(-KNOCKBACK_FACTOR, -100)	
		
	else:
		knockback = Vector2(KNOCKBACK_FACTOR, -100)	
		
	current_health -= damage
	
	var health_display = round(current_health/HEALTH * 100)
	
	health_label.text = "[center]" + str(current_health) +"[/center]"
	health_bar.value = health_display
	if current_health <= 0:
		dead()
		
	if motion_mode == CharacterBody2D.MOTION_MODE_GROUNDED:
		if is_on_floor():
			velocity = knockback			
	else:
		velocity = knockback
	custom_hit()
	
func dead():
	anim.play("dead")
	camera_shake.screen_shake_short_strong()
	set_physics_process(false)	
	rip = true
	sprite.visible = false
	boom.visible = true
	parent.visible = false
	hitbox.disabled = true
	dead_sfx.play()
	boom.play()
	drop()
	$Dead.start()
	Global.score += 1000
	if Global.enable_particle:
		$Blood.emitting = true
	custom_death()
	
	if Global.lock_queue.find(self) >= 0 and Global.local_target_querry.find(self) >= 0:
		Global.lock_queue.remove_at(Global.lock_queue.find(self))
		Global.local_target_querry.remove_at(Global.local_target_querry.find(self))
	
	Global.current_locked -= 1
	if Global.current_locked <= 0:
		Global.current_locked = 0

func is_dead() -> bool:
	return rip

func _on_boom_animation_looped():
	boom.visible = false

func drop():
	var rng_range:int = 3
	#if !Global.obtained_specials:
	#	rng_range = 3
	var rng1 = randi_range(rng_range,rng_range + 1)
	for i in range(rng1):
		var rng_drop = randi_range(1,rng_range)
		var rng2 = randf_range(-300,300)
		var rng3 = randf_range(500,300)
		
		match rng_drop:
			1:
				var ammo_drop_node: Node2D = ammo_drop.instantiate()
				get_tree().get_current_scene().call_deferred("add_child", ammo_drop_node)
				var ammo: RigidBody2D = ammo_drop_node.get_node("Dropable")
				ammo.global_position = global_position
				ammo.linear_velocity = Vector2(rng2, -rng3)
			2:
				var health_drop_node: Node2D = health_drop.instantiate()
				get_tree().get_current_scene().call_deferred("add_child", health_drop_node)
				var health: RigidBody2D = health_drop_node.get_node("Dropable")
				health.global_position = global_position
				health.linear_velocity = Vector2(rng2, -rng3)
			3:
				var secondary_drop_node: Node2D = secondary_drop.instantiate()
				get_tree().get_current_scene().call_deferred("add_child", secondary_drop_node)
				var secondary: RigidBody2D = secondary_drop_node.get_node("Dropable")
				secondary.global_position = global_position
				secondary.linear_velocity = Vector2(rng2, -rng3)

func spawn():
	anim.play("spawn")
	
func pit():
	$Dead.start()

func _on_dead_timeout():
	get_parent().call_deferred("queue_free")
