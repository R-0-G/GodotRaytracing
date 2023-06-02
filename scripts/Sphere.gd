extends Node3D

class_name Sphere

@export var colour : Color

func get_info():
	return [global_position, scale.x, colour]
