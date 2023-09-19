extends Line2D

var queue_trail: Array
var body: Object
var MAX_LENGTH: int

func _physics_process(delta):
	if body != null:
		queue_trail.push_front(body.global_position)
	
		if queue_trail.size() > MAX_LENGTH:
			queue_trail.pop_back()
			
		clear_points()
		for p in queue_trail:
			add_point(p)
	else:
		var tween1:Tween = create_tween()
		tween1.tween_property(self, "modulate:a", 0.0, 0.2)
		tween1.connect("finished", on_tween_finished)
			
func on_tween_finished():
	queue_free()
