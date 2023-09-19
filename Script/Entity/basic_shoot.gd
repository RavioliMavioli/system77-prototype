class_name Shoot extends Node

var projectile:PackedScene
var post_shoot:PackedScene
var sfx:PackedScene
var entity_global_position: Vector2
var mouse_position: Vector2

var character: CharacterBody2D
var aim_center: Marker2D
var bullet_spawn: Marker2D

var direction: Vector2
var rad: float
var unix_time: float
var ticks: float = 0.01
var clock: int = 0
var last_shot_time: float = 0.0

func _init(body:CharacterBody2D, aimcenter:Marker2D, bulletspawn:Marker2D):
	character = body
	aim_center = aimcenter
	bullet_spawn = bulletspawn
	
func set_projectile(path:String):
	projectile = load(path)
	
func set_post_shoot(path:String):
	post_shoot = load(path)
	
func set_sfx(path:String):
	sfx = load(path)

func shoot():
	if rounds_per_minute(6000):
		shoot_bullet(30.0, 20.0, 9, 3.0, 0)
		play_sound()

func initialize_for_player():
	entity_global_position = character.global_position
	mouse_position = character.get_global_mouse_position()
	direction = entity_global_position - mouse_position
	rad = direction.angle() + PI
	aim_center.rotation = rad
	clocks()

func initialize_for_entity(aim:Vector2):
	entity_global_position = character.global_position
	direction = entity_global_position - aim
	rad = direction.angle() + PI
	aim_center.rotation = rad
	clocks()
	
func get_spawn_bullet_init():
	var new_bullet = projectile.instantiate()
	character.get_parent().add_child(new_bullet)
	new_bullet.global_position = bullet_spawn.global_position
	new_bullet.global_rotation = bullet_spawn.global_rotation
	return new_bullet

func rounds_per_minute(fire_rate_rpm:float):
	if clock % int(1/fire_rate_rpm * 60000) == 0:
		return true

func play_sound():
	var new_gun_sound:AudioStreamPlayer2D = sfx.instantiate()
	character.get_parent().add_child(new_gun_sound)
	new_gun_sound.global_position = character.global_position
	

func shoot_bullet(bullet_spread:float, bullet_spread_degrees:float, bullet_ammount:int, curve_factor:float, gap:int):
	var listed_gap:Array = []
	if gap > 0:
		for j in range(gap):
			listed_gap.append(bullet_ammount/2 + j)
			listed_gap.append(bullet_ammount/2 - j)
			
	for i in range(bullet_ammount):
		if i in listed_gap:
			pass
		else:
			var new_bullet: Sprite2D = get_spawn_bullet_init()
			var spawn_line = bullet_spread/2 - ( i * bullet_spread/(bullet_ammount-1) )
			var spawn_line_normalized = spawn_line / (bullet_spread/2)
	
			var curved_spawn_line:float
			curved_spawn_line = curve_factor * cos(spawn_line_normalized*PI/2)
	
			new_bullet.global_position.y += spawn_line
			
			# X = Ax + (Bx - Ax) cos a - (By - Ay) sin a
			# Y = Ay + (Bx - Ax) sin a + (By - Ay) cos a
			
			var Ax = bullet_spawn.global_position.x
			var Ay = bullet_spawn.global_position.y
			var Bx = new_bullet.global_position.x + curved_spawn_line
			var By= new_bullet.global_position.y
			var alpha = new_bullet.global_rotation

			var new_position:Vector2 = Vector2(0,0)
					
			new_position.x = Ax + (Bx - Ax) * cos(alpha) - (By - Ay) * sin(alpha)
			new_position.y = Ay + (Bx - Ax) * sin(alpha) + (By - Ay) * cos(alpha)
		
			
			new_bullet.global_position.x = new_position.x
			new_bullet.global_position.y = new_position.y 
			new_bullet.global_rotation += deg_to_rad( bullet_spread_degrees/2 - (i * bullet_spread_degrees/(bullet_ammount-1)) )


func shoot_single_bullet():
	get_spawn_bullet_init()

func shoot_homing_missile(body):
	var new_bullet = projectile.instantiate()
	character.get_parent().add_child(new_bullet)
	new_bullet.global_position = bullet_spawn.global_position
	new_bullet.global_rotation = bullet_spawn.global_rotation
	play_sound()
	new_bullet.target = body
	return new_bullet

func clocks():
	unix_time = Time.get_unix_time_from_system()
	if (unix_time - last_shot_time) >= ticks:
		last_shot_time = unix_time
		clock += 1

	if clock > 1000:
			clock = 0
		
