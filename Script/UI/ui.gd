extends Control

func _ready():
	pass
	
func _physics_process(delta):
	var display_ammo = 100 - (100*Global.shoot_L_ammo/Global.max_ammo)
	var display_special = 100 - (100*Global.shoot_R_ammo/Global.max_ammo)
	var health_display = (100*Global.player_health/200)
	$Ammo/Ammo/Text/LAmmo.value = display_ammo
	$Ammo/Ammo/Text/RAmmo.value = display_special
	$Health/Healthbar.value = Global.player_health
	$Score.text = str(Global.score)
	
	$HighScore.text = str(max(Global.score, Global.high_score))
	
	if Global.score >= Global.high_score:
		Global.high_score = Global.score


func _on_l_ammo_timeout():
	Global.shoot_L_ammo -= 1


func _on_r_ammo_timeout():
	#Global.shoot_R_ammo -= 1
	pass
