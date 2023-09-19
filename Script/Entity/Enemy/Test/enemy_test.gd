extends RigidBody2D

@export var KNOCKBACK_FACTOR:int

@onready var health_label:RichTextLabel = $Control/ControlHealthLabel/HealthLabel
@onready var health_bar:TextureProgressBar = $Control/ControlHealthBar/HealthBar
@onready var parent:Node2D = $Control
@onready var boom:AnimatedSprite2D = $Boom
@onready var dead_sfx:AudioStreamPlayer2D = $DeadSFX
@onready var sprite:Sprite2D = $Icon
@onready var hitbox:CollisionShape2D = $CollisionShape2D
@onready var camera_shake: ScreenShake = ScreenShake.new(get_tree().current_scene.get_node("Camera2D"))


var ammo_drop:PackedScene = preload("res://Script/Dropable/Ammo/ammo_drop.tscn")
var secondary_drop:PackedScene = preload("res://Script/Dropable/Secondary Ammo/secondary_drop.tscn")
var health_drop:PackedScene = preload("res://Script/Dropable/Health/health_drop.tscn")

var offset_y:float = -50
var health = 100
var rip = false

func _ready():
	sprite.visible = true
	boom.visible = false

func _physics_process(_delta):
	parent.global_position = global_position
	parent.global_rotation = 0.0
	
func get_shot(bullet_position:Vector2, damage:int):
	
	camera_shake.screen_shake_short_weak()
	
	var knockback:Vector2 = global_position - bullet_position
	var knockback_direction = knockback.x
	
	if knockback_direction >= 0:
		
		knockback = Vector2(KNOCKBACK_FACTOR, -3)	
		
	else:
		knockback = Vector2(-KNOCKBACK_FACTOR, -3)	
		
	health -= damage
	health_label.text = "[center]" + str(health) +"[/center]"
	health_bar.value = health
	if health <= 0:
		dead()
	
	move_and_collide(knockback)
func dead():
	$AnimationPlayer.play("dead")
	camera_shake.screen_shake_short_strong()
	set_physics_process(false)	
	freeze = true
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

func is_dead() -> bool:
	return rip

func _on_boom_animation_looped():
	boom.visible = false

func drop():
	var rng_range:int = 4
	#if !Global.obtained_specials:
	#	rng_range = 3
	var rng1 = randi_range(rng_range-1,rng_range)
	for i in range(rng1):
		var rng_drop = randi_range(1,rng_range)
		var rng2 = randf_range(-300,300)
		var rng3 = randf_range(500,300)
		
		match rng_drop:
			1:
				var ammo_drop_node: Node2D = ammo_drop.instantiate()
				get_tree().get_current_scene().add_child(ammo_drop_node)
				var ammo: RigidBody2D = ammo_drop_node.get_node("Dropable")
				ammo.global_position = global_position
				ammo.linear_velocity = Vector2(rng2, -rng3)
			2:
				var ammo_drop_node: Node2D = ammo_drop.instantiate()
				get_tree().get_current_scene().add_child(ammo_drop_node)
				var ammo: RigidBody2D = ammo_drop_node.get_node("Dropable")
				ammo.global_position = global_position
				ammo.linear_velocity = Vector2(rng2, -rng3)
			3:
				var health_drop_node: Node2D = health_drop.instantiate()
				get_tree().get_current_scene().add_child(health_drop_node)
				var health: RigidBody2D = health_drop_node.get_node("Dropable")
				health.global_position = global_position
				health.linear_velocity = Vector2(rng2, -rng3)
			4:
				var secondary_drop_node: Node2D = secondary_drop.instantiate()
				get_tree().get_current_scene().add_child(secondary_drop_node)
				var secondary: RigidBody2D = secondary_drop_node.get_node("Dropable")
				secondary.global_position = global_position
				secondary.linear_velocity = Vector2(rng2, -rng3)

func _on_dead_timeout():
	queue_free()
