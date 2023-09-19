extends RigidBody2D

@onready var character: CharacterBody2D = $"../Player"

func _on_area_2d_body_entered(body):
	character.is_hooked = true
