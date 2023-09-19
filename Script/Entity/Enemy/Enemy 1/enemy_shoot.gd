class_name EnemyShoot extends Shoot

func shoot():
	
	var rand = randi_range(1,3)
	if rounds_per_minute(300):
		
		shoot_bullet(1.0, 360/rand, rand, 0.0, 0)
		play_sound()
		
