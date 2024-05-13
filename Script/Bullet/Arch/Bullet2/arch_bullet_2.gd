extends Bullet

var target: Object = null
var sine = PI
var trail:Trail = Trail.new(20, 10, "res://Script/curve1.tres", self, Color("ffd395"))

var velocity: Vector2
var direction: Vector2

var drag_factor = 0.2

var once = true

func custom_ready():
	trail.trail_ready()

func bullet_behaviour(delta):
	if once:
		direction = Vector2.RIGHT.rotated(rotation)
		velocity = SPEED * Vector2.RIGHT.rotated(rotation)
		once = false
	#sine += delta*SPEED/20
	#var distance = SPEED*delta
	#var motion_x = transform.x * distance 
	#var motion_y = transform.y * -sin(sine) * delta*SPEED
	#position += motion_x
	#position += motion_y
	
	if is_instance_valid(target) and not target.is_dead():
		direction = global_position.direction_to(target.global_position)
	var desired_velocity = direction * SPEED
	var change = (desired_velocity - velocity) * drag_factor
		
	velocity += change	
	position += velocity * delta
	look_at(global_position + velocity)
	
