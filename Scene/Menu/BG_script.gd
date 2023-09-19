extends Node2D


@onready var arch: Sprite2D = $Front/arch
@onready var lfs: Sprite2D = $Front/lfs

var lerp_weight = 0.05

func _ready():
	if Global.continuable:
		Global.current_character = Global.characters.find("lfs")
	else:
		Global.current_character = Global.characters.find("arch")

func init():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.warp_mouse(get_viewport().size/2)
	$Timer.start()
	$Back.global_position = Vector2(80,0)
	$Front.global_position = Vector2(100,0)
	$ParticleParent.global_position = Vector2(100,0)
	$"../MenuText".global_position = Vector2(-200,0)
	
func _physics_process(delta):
	
	hide_all()
	show_char(Global.characters[Global.current_character])
	
	var mouse_pos = get_global_mouse_position()
	
	$Back.global_position = lerp($Back.global_position, -mouse_pos/60, lerp_weight)
	$Front.global_position = lerp($Front.global_position, -mouse_pos/30, lerp_weight)
	$ParticleParent.global_position = lerp($ParticleParent.global_position, -mouse_pos/15, lerp_weight)

func hide_all():
	arch.hide()
	lfs.hide()

func show_char(char):
	$Front.get_node(char).visible = true

func _on_timer_timeout():
	lerp_weight = 0.1
