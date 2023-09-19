class_name Trail extends Node2D

var trail:PackedScene = preload("res://Script/Trail/trail.tscn")
var trail_node: Line2D
var body: Object
var color: Color
var curve: Curve
var width: float
var MAX_LENGTH:int

func _init(_max_length: int, _width: float, _curve_path: String, _body: Object, _color:Color):
	
	curve = load(_curve_path)
	body = _body
	color = _color
	width = _width
	MAX_LENGTH = _max_length
	
func trail_ready():
	trail_node = trail.instantiate()
	body.get_tree().get_current_scene().add_child(trail_node)
	
	trail_node.width = width
	trail_node.width_curve = curve
	trail_node.default_color = color
	trail_node.body = body
	trail_node.width_curve = curve
	trail_node.MAX_LENGTH = MAX_LENGTH
	
func set_trail_gradient(grandient):
	trail_node.gradient = grandient
	
