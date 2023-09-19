extends Node2D


var crosshair = load("res://Resources/crosshair.png")
var spawner = SpawnEntity.new()

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var marker:Marker2D = $Enemyspawn

var movemove = 2
func _ready():
	spawner.spawn_player(self, $PlayerSpawn)
	Input.set_custom_mouse_cursor(crosshair,0,Vector2(50,50)) 															
	
func _physics_process(_delta):
	
	marker.global_position.x  += movemove
	if marker.global_position.x >= 1200.0:
		movemove = -movemove
	if marker.global_position.x <= 100.0:
		movemove = -movemove

func spawn_random_enemy():
	
	spawner.spawn_enemy(self, marker.global_position)


func _on_spawn_timer_timeout():
	spawn_random_enemy() # Replace with function body.
