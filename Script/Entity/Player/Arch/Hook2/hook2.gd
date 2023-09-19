extends Node2D

@onready var links: Sprite2D = $Link
@onready var tip: CharacterBody2D = $Tip

var hook_node: Node2D
var direction: Vector2
var tip_position: Vector2
var delta_tip_position:Vector2

var hook_max_length: float
var speed: float

var reverse = false
var flying = false
var hooked = false

func shoot(dir: Vector2, hook_aim: Node2D, hook_velocity:float, hook_max:float):
	speed = hook_velocity
	direction = dir.normalized()
	flying = true
	tip_position = hook_aim.global_position
	hook_node = hook_aim
	hook_max_length = hook_max

func release():
	flying = false
	hooked = false
	reverse = false

func retract():
	reverse = true
	hooked = false
	flying = true

func _process(delta):
	self.visible = flying or hooked
	if !self.visible:
		return
		
	delta_tip_position = tip.global_position - hook_node.global_position
	
	#tip.global_rotation = direction.angle() + PI/2
	tip.global_rotation = (tip.global_position - hook_node.get_parent().global_position).angle() + PI/2
	links.global_rotation = delta_tip_position.angle() + PI/2
	links.global_position = tip.global_position 
	links.region_rect.size.y = delta_tip_position.length()

func _physics_process(delta):
	tip.global_position = tip_position	# The player might have moved and thus updated the position of the tip -> reset it
	if flying:
		var delta_position = hook_node.global_position - tip_position
		# `if move_and_collide()` always moves, but returns true if we did collide
		if delta_position.length() > hook_max_length:
			reverse = true
			
		if reverse:
			$Tip/CollisionShape2D.disabled = true
			tip.velocity = delta_position.normalized() * speed * 100
			tip.move_and_slide()

			if delta_position.length() <= 50:
				release()
				
		else:
			$Tip/CollisionShape2D.disabled = false
			if tip.move_and_collide(direction * speed):
				hooked = true	# Got something!
				flying = false	# Not flying anymore

			

	tip_position = tip.global_position	# set `tip`
