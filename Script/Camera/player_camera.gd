extends Camera2D

const VERTICAL_OFFSET = -30.0
const DM = 1.3
const MM = 4

var player:CharacterBody2D = CharacterBody2D.new()
var offset_x
var player_global_position:Vector2 = Vector2(0,0)
var camera_position
var window_size
var init = true

func _ready():
	
	$ColorRect.hide()
	$"../Start".play("start")
	Global.camera_node = self
	
	offset_x = 0.0
	window_size = Vector2(get_window().size)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	init_player_once()
	var tween: Tween = get_tree().create_tween()
	var mouse_pos = get_global_mouse_position()
	var d_position = mouse_pos - global_position
	
	player_global_position = player.global_position
	
	# Camera follows player
	global_position.x = lerp(global_position.x, player_global_position.x + offset_x, delta * MM)
	global_position.y = lerp(global_position.y, player_global_position.y + VERTICAL_OFFSET, delta * MM)

	# Camera follows cursor
	if abs(d_position.x) < 400.0:
		global_position.x = lerp(global_position.x, mouse_pos.x, delta * DM)
	else:
		global_position.x = lerp(global_position.x, global_position.x + isPositive(d_position.x)*400.0, delta * DM)
		
	if abs(d_position.y) < 256.0:
		global_position.y = lerp(global_position.y, mouse_pos.y + VERTICAL_OFFSET, delta * DM)
	else:
		global_position.y = lerp(global_position.y, global_position.y + isPositive(d_position.y)*256.0 + VERTICAL_OFFSET, delta * DM)

	if mouse_pos.x - player_global_position.x < 0:
		tween.tween_property(self, "offset_x", -130.0 , 2.0)
	else:
		tween.tween_property(self, "offset_x", 130.0 , 2.0)
		
func isPositive(x: float):
	if x>=0:
		return 1.0
	else:
		return -1.0
		
func init_player_once():
	if init:
		player = get_parent().get_node("MainPlayer").get_node("Player")
		global_position = player.global_position
		init = false

func entity_get_shot():
	print("AD")

