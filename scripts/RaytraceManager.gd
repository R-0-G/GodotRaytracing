extends Node

#use 3d texture instead of this crap

@export var objects : Array[Sphere]
@export var tex_rect : TextureRect

var locations_texture : ImageTexture
var sizes_texture : ImageTexture
var colours_texture : ImageTexture

var shadmat
var min_bounds : Vector3
var max_bounds : Vector3

func _ready():
	calculate_properties()
	set_properties()
	
func calculate_properties():
	objects = [$"Sphere visualizer" as Sphere]
	calc_bounds()
	
	var colours_image = Image.create(len(objects), 1, false, Image.FORMAT_RGBAF)
	for i in len(objects):
		colours_image.set_pixel(i, 0, objects[i].get_info()[2])
	colours_texture = ImageTexture.create_from_image(colours_image)
	
	var positions_image = Image.create(len(objects), 1, false, Image.FORMAT_RGBAF)
	for i in len(objects):
		var pos = objects[i].get_info()[0]
		var x = pos.x / (max_bounds.x - min_bounds.x)
		var y = pos.y / (max_bounds.y - min_bounds.y)
		var z = pos.z / (max_bounds.z - min_bounds.z)
		positions_image.set_pixel(i, 0, Color(x,y,z)) #todo need to consolidate the z issue
	locations_texture = ImageTexture.create_from_image(positions_image)
	
	var sizes_image = Image.create(len(objects), 1, false, Image.FORMAT_RGBAF)
	for i in len(objects):
		var rad = objects[i].get_info()[1]
		sizes_image.set_pixel(i, 0, Color(rad, 0.0,0.0) )
	sizes_texture = ImageTexture.create_from_image(sizes_image)
	
	shadmat = (tex_rect.material as ShaderMaterial)
	
func calc_bounds():
	if len(objects) > 0:
		min_bounds = objects[0].get_info()[0]
		max_bounds = objects[0].get_info()[0]
	else:
		min_bounds = Vector3.ZERO
		max_bounds = Vector3.ZERO
	
	for o in objects:
		var vec = o.get_info()[0]
		if vec.x < min_bounds.x:
			min_bounds.x = vec.x
		if vec.x > max_bounds.x:
			max_bounds.x = vec.x
		if vec.y < min_bounds.y:
			min_bounds.y = vec.y
		if vec.y > max_bounds.y:
			max_bounds.y = vec.y	
		if vec.z < min_bounds.x:
			min_bounds.z = vec.z
		if vec.z > max_bounds.z:
			max_bounds.z = vec.z




func set_properties():
	if shadmat!=null:
		if locations_texture != null:
			shadmat.set_shader_parameter("sphere_locations", locations_texture ) 
		if sizes_texture != null:
			shadmat.set_shader_parameter("sphere_sizes", sizes_texture ) 
		if colours_texture != null:
			shadmat.set_shader_parameter("sphere_colours", colours_texture ) 
		shadmat.set_shader_parameter("max_bounds", max_bounds ) 
		shadmat.set_shader_parameter("min_bounds", min_bounds ) 
		shadmat.set_shader_parameter("sphere_count", len(objects))

