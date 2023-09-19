class_name ArchShoot extends Shoot

func shoot_1():
	Global.fire_type = 1
	Global.fire_rate = 10000
	match Global.fire_type:
		1:
			if rounds_per_minute(Global.fire_rate):
				if Global.shoot_L_ammo < Global.max_ammo:
					Global.shoot_L_ammo += 1
					shoot_bullet(20.0, 0.0, 2, 0.0, 0)
					play_sound()
					return true
				else:
					return false
		2:
			if rounds_per_minute(Global.fire_rate):
				if Global.shoot_L_ammo < Global.max_ammo:
					Global.shoot_L_ammo += 1
					shoot_bullet(30.0, 5.0, 3, 3.0, 0)
					play_sound()
					return true
				else:
					return false
					
		3:
			if rounds_per_minute(Global.fire_rate):
				if Global.shoot_L_ammo < Global.max_ammo:
					Global.shoot_L_ammo += 1
					shoot_bullet(40.0, 8.0, 5, 10.0, 0)
					play_sound()
					return true
				else:
					return false
			
