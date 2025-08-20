extends Node3D

var rotation_speed = 10

func _process(delta: float) -> void:
	rotation_degrees.y += delta * rotation_speed
