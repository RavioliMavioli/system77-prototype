extends ColorRect

var center: Vector2
var offset: Vector2
var MIN_CA = 0.5
var MAX_CA = 1.5

func _ready():
	show()
	if !Global.chromatic:
		hide()

func _physics_process(delta):
		
	center = size/2
	var mouse_delta:Vector2 = (get_local_mouse_position() - center ).normalized()
	var current_offset:Vector2 = Vector2(material.get_shader_parameter("strength_x"), material.get_shader_parameter("strength_y"))
	offset = mouse_delta*MAX_CA
	#################### CHROMATIC ABBERATION #################### 

	if abs(offset.x) <= MIN_CA:
		if offset.x > 0:
			offset.x = min(offset.x, MIN_CA)
		else:
			offset.x = max(offset.x, -MIN_CA)
	if abs(offset.y) <= MIN_CA:
		if offset.y > 0:
			offset.y = min(offset.x, MIN_CA)
		else:
			offset.y = max(offset.x, -MIN_CA)
	
	material.set_shader_parameter("strength_x", lerp(current_offset.x, offset.x, delta*5))
	material.set_shader_parameter("strength_y", lerp(current_offset.y, offset.y, delta*5))
