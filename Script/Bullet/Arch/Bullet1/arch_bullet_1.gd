extends Bullet

var sine = PI

func bullet_behaviour(delta):
	sine += delta*10
	var distance = SPEED*delta
	var motion_x = transform.x * distance 
	#var motion_y = transform.y * -sin(sine) * 3
	position += motion_x
	#position += motion_y
