extends Dropable

func pick():
	Global.shoot_R_ammo -= 10
	
func custom_ready():
	change_light_color(Color("ffbd7e"))
	change_trail_color(Color("ffbd7e"))
