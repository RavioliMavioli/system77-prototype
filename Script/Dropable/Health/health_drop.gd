extends Dropable

func pick():
	
	Global.player_health += 10
	
func custom_ready():
	change_light_color(Color("ff4f5f"))
	change_trail_color(Color("ff4f5f"))
