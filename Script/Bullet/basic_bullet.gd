class_name Bullet extends Sprite2D

@export var DAMAGE: int
@export var SPEED: int
@export var LIFETIME:float

@onready var bullet: Object = $Bullet
@onready var boom: AnimatedSprite2D = $Boom
#@onready var bloom: PointLight2D = $Bloom
@onready var collision: CollisionShape2D = $Collision
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var particle: GPUParticles2D = $Particles

var collision_mask_1 = 0b0001 # Bit 1
var collision_mask_2 = 0b1000  # Bit 4

var collided = false
var unix_time: float
var start_time: float = 0.0
var start_collided_time: float = 0.0

var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

func bullet_behaviour(delta):
	var distance = SPEED*delta
	var motion = transform.x * distance
	position += motion

func custom_ready():
	pass

func _ready():
	start_time = Time.get_unix_time_from_system()
	
	query.set_shape(collision.shape)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = collision_mask_1 | collision_mask_2
	
	custom_ready()
	
func _physics_process(delta):
	
	unix_time = Time.get_unix_time_from_system()

	if (unix_time - start_time) >= LIFETIME:
		bullet_destroyed()
		queue_free()	

	if !collided:
		bullet_behaviour(delta)
		
		query.transform = global_transform
		var results: Array = get_world_2d().direct_space_state.intersect_shape(query, 1)
		for result in results:
			var entity = result["collider"]
			if entity.has_method("get_shot"):
				entity.get_shot(global_position, DAMAGE)
			sfx.play()
			explode()
	else:
		bullet_behaviour_post_collision(delta)
		if (unix_time - start_collided_time) >= 2:
			queue_free()

func bullet_behaviour_post_collision(delta):
	pass

func custom_explode():
	pass

func bullet_destroyed():
	pass

func explode():
	collided = true
	if Global.enable_particle:
		particle.emitting = true
	bullet.visible = false
	boom.show()
	boom.play("boom")
	var tween1:Tween = create_tween()
	#var tween2:Tween = create_tween()
	tween1.tween_property(boom, "modulate:a", 0.0, 0.3)
	#tween2.tween_property(bloom, "energy", 0.0, 0.3)
	start_collided_time = Time.get_unix_time_from_system()
	custom_explode()
