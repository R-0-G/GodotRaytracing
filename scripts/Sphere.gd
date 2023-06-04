extends Node3D

class_name Sphere

@export var mesh : MeshInstance3D

func get_info():
	var mat = mesh.material_override as StandardMaterial3D	
	var emission_amount = 0
	if mat.emission_enabled:
		emission_amount = mat.emission_energy_multiplier

	return [global_position, scale.x/2, mat.albedo_color, mat.emission, emission_amount ]
