extends Enemy
const JUMP = -500
var active = false

@onready var shoot = EnemyShoot.new(self, $Marker2D, $Marker2D)


func custom_ready():
	shoot.set_projectile("res://Script/Entity/Enemy/Enemy 1/enemy_bullet_1.tscn")
	#shoot_l.set_post_shoot("res://Script/Bullet/bullet_case.tscn")
	shoot.set_sfx("res://Script/Bullet/Enemy/enemy_bullet_1_sfx.tscn")

func enemy_behaviour(delta):
	$Sprite.play("idle")
	if delta_player_position.x < 800 and delta_player_position.y < 800:
		active = true
	else:
		active = false
	
	
	if active:
		var direction:float = delta_player_position.x
		if direction < 0:
			direction = -1
		else:
			direction = 1
		
		velocity.x = lerp(velocity.x, direction*300, delta*5)
		
		if is_on_floor() and !$GroundLonger.is_colliding():
			velocity.y = JUMP
		
		if ($Front.is_colliding() or $Back.is_colliding()) and is_on_floor():
			velocity.y = JUMP
	
	if delta_player_position.x < 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false

	shoot.initialize_for_entity(Global.player_current_global_position)
	shoot.shoot()

func _on_jump_player_timeout():
	if active and abs(delta_player_position.x) < 100 and delta_player_position.y < -100 and is_on_floor():
		velocity.y = JUMP
