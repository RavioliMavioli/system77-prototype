class_name Dropable extends RigidBody2D

@onready var sfx_drop: AudioStreamPlayer2D = $SFXDrop
@onready var sfx_pick: AudioStreamPlayer2D = $SFXPick

var player: CharacterBody2D
var picked = false
var once = true
var trail:Trail = Trail.new(20, 5, "res://Script/curve1.tres", self, Color("83ddff"))

func custom_ready():
	pass

func pick():
	Global.shoot_L_ammo -= 5

func change_light_color(color: Color):
	$PointLight2D.color = color

func change_trail_color(color: Color):
	trail.color = color
	
func _ready():
	$AnimationPlayer.play("animation")
	custom_ready()
	trail.trail_ready()
	
func _physics_process(delta):
	if picked:
		freeze = true
		global_position = lerp(global_position, player.global_position, delta*10)
		if once and global_position.distance_to(player.global_position) < 30:
			$AnimationPlayer.play("pick")
			sfx_pick.play()
			pick()
			once = false
	
func _on_animation_player_animation_finished(anim_name):
	get_parent().queue_free()


func _on_area_2d_body_entered(body):
	if "Player" in body.name:
		player = body
		picked = true


func _on_ground_body_entered(body):
	sfx_drop.play()
