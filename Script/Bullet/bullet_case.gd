extends RigidBody2D

@onready var timer:Timer = get_node("DeleteCase")
@onready var case:Sprite2D = get_node("Case")
@onready var sound:AudioStreamPlayer = get_node("Sound")
@onready var collision:CollisionShape2D = get_node("CollisionShape2D")
var once = 1
func _physics_process(_delta):
	
	if timer.get_time_left() <= 0.5:
		var tween:Tween = create_tween()
		tween.tween_property(case, "modulate:a", 0.0, 0.3)
		

func _on_delete_case_timeout():
	queue_free()


func _on_body_entered(_body):
	if once <= 5:
		sound.play()
		once += 1
