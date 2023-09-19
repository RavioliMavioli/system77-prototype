extends Dropable

func pick():
	Global.shoot_L_ammo -= 15
	
func custom_ready():
	change_light_color(Color("84deff"))
	change_trail_color(Color("84deff"))
