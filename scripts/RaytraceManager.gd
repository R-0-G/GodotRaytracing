extends Node

#use 3d texture instead of this crap

@export var tex_rect : TextureRect
@export var bounces : int
@export var num_ray_per_pix : int

var objects : Array[Node]
var shadmat
var locations : Array[Vector3]
var sizes : Array[float]
var colours : Array[Vector3]
var emi_colours : Array[Vector3]
var emi_strs : Array[float]


func _ready():
	calculate_properties()
	set_properties()
	
#func _process(_delta):
#	calculate_properties()
#	set_properties()
	
func calculate_properties():
	objects = find_children("*", "Sphere", false) 
	
	for obj in objects:
		var data = (obj as Sphere).get_info()
		locations.append(data[0])
		sizes.append(data[1])
		colours.append(Vector3(data[2].r, data[2].g, data[2].b))
		emi_colours.append(Vector3(data[3].r, data[3].g, data[3].b))
		emi_strs.append(data[4])
	
	shadmat = (tex_rect.material as ShaderMaterial)
	




func set_properties():
	if shadmat!=null:
		if locations != null:
			shadmat.set_shader_parameter("sphere_locations", locations ) 
		if sizes != null:
			shadmat.set_shader_parameter("sphere_sizes", sizes ) 
		if colours != null:
			shadmat.set_shader_parameter("sphere_colours", colours ) 
		if emi_colours != null:
			shadmat.set_shader_parameter("sphere_emissions", emi_colours)
		
		shadmat.set_shader_parameter("sphere_count", len(objects))
		shadmat.set_shader_parameter("max_bounce", bounces)
		shadmat.set_shader_parameter("sphere_emission_strs", emi_strs)
		shadmat.set_shader_parameter("num_ray_per_pix", num_ray_per_pix)

