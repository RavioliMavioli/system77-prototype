extends Node2D

var hook_piece = preload("res://Script/Entity/Player/Arch/Hook/hook_piece.tscn")
var piece_length: float = 4
var hook_parts: Array = []
var hook_close_tolerance = 4.0

@onready var hook_start: RigidBody2D = $hook_start
@onready var hook_end: RigidBody2D = $hook_end


func spawn_hook(start_pos:Vector2, end_pos:Vector2):
	var distance = start_pos.distance_to(end_pos)
	var segments_ammount = round(distance / piece_length)
	var spawn_angle = (end_pos - start_pos).angle() - PI/2
	
	hook_start.global_position = start_pos
	hook_end.global_position = end_pos
	
	start_pos = hook_start.get_node("Collision/Joint").global_position
	end_pos = hook_end.get_node("Collision/Joint").global_position

	create_hook(segments_ammount, hook_start, end_pos, spawn_angle)
	
func create_hook(piece_ammount:int, parent:Object, end_pos:Vector2, spawn_angle:float):
	
	for i in piece_ammount:
		
		parent = add_piece(parent, i ,spawn_angle)
		hook_parts.append(parent)
		
		var joint_pos = parent.get_node("Collision/Joint").global_position
		
		if joint_pos.distance_to(end_pos) < hook_close_tolerance:
			break	
	hook_end.get_node("Collision/Joint").node_a = hook_end.get_path()
	hook_end.get_node("Collision/Joint").node_b = hook_parts[-1].get_path()
	
func add_piece(parent: Object, id:int, spawn_angle:float):
	var joint: PinJoint2D = parent.get_node("Collision/Joint")
	var piece : RigidBody2D = hook_piece.instantiate()
	
	piece.global_position = joint.global_position
	piece.rotation = spawn_angle
	piece.parent = self
	piece.id = id
	add_child(piece)
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	
	return piece
	
