extends Bullet

var sine = PI

func custom_ready():
	var c1 = 0b0001
	var c2 = 0b100000
	query.collision_mask = c1 | c2

func bullet_behaviour(delta):
	var distance = SPEED*delta
	var motion_x = transform.x * distance 
	#var motion_y = transform.y * -sin(sine) * 3
	position += motion_x
	#position += motion_y
