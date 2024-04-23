@tool
extends EditorPlugin

@onready var overlay = ColorRect.new()
@onready var material = preload("res://addons/ROGodot/ROGOverlay/CanvasOverlayMaterial.tres")
@onready var mat = preload("res://funmat.tres")
var bounces =2
var num_ray_per_pix =10

var frame_count = 0

var objects : Array[Node]
var shadmat
var locations : Array[Vector3]
var sizes : Array[float]
var colours : Array[Vector3]
var emi_colours : Array[Vector3]
var emi_strs : Array[float]


var is_active = false
var cam : Camera3D
var tex : Texture2D

@onready var tick : float = 0.2

var timer =0;



func _enter_tree():
	add_tool_menu_item("CameraTest", cam_test)
	
func cam_test():
	set_active(!is_active)
	
func _process(delta):
	timer += delta
	if timer < tick:
		pass
	else:
		timer=0
		
	if is_active:
		#if tex!=null:
			#mat.albedo_texture = tex
			#material.set_shader_parameter("last_tex", tex)
		
		var size = DisplayServer.window_get_size()
		#var near_plane =  cam.get_frustum()[0]
		var near = cam.near
		var plane_height = near * tan( deg_to_rad(cam.fov * 0.5 )) * 2
		var aspect = size.aspect()
		var plane_width = plane_height * aspect
		var view_params = Vector3(plane_width, plane_height, near)

		var glob_pos = cam.get_global_position()
		var mat = cam.transform
		#matty = mat.affine_inverse()
		#var proj = Projection(mat.affine_inverse())
		var proj = Projection(mat)
		proj.x.w = cam.global_position.x
		proj.y.w = cam.global_position.y
		proj.z.w = cam.global_position.z #crap that i have to do this
		proj.w = Vector4.ZERO
		#projjy = proj
#		
		#var vp = Vector4(0.0,0.0,1.0, 1.0)
		#var vpg = vp*proj
		#print(vpg, " : ", Vector3(vpg.x, vpg.y, vpg.z)- glob_pos)
		
		material.set_shader_parameter("frustrum_info",Plane(view_params)) #crap that i have to do this
		material.set_shader_parameter("cam_local_world", proj)
		material.set_shader_parameter("world_space_camera_pos", Plane(glob_pos)) #crap that i have to do this
		material.set_shader_parameter("screen_pixel_size", Vector2(size.x,size.y)) #crap that i have to do this
		#var img = overlay.get_viewport().get_texture().get_image()
		#tex = ImageTexture.create_from_image(img)
		


	
func calculate_properties():
	objects = get_tree().edited_scene_root.find_children("*", "Sphere", false)
	print ("objs: "+ str(len(objects)))
	
	for obj in objects:
		var sp = obj as Sphere
		var data = sp.get_info_sp()
		locations.append(data[0])
		sizes.append(data[1])
		colours.append(Vector3(data[2].r, data[2].g, data[2].b))
		emi_colours.append(Vector3(data[3].r, data[3].g, data[3].b))
		emi_strs.append(data[4])

	




func set_properties():
	if material!=null:
		if locations != null:
			material.set_shader_parameter("sphere_locations", locations ) 
		if sizes != null:
			material.set_shader_parameter("sphere_sizes", sizes ) 
		if colours != null:
			material.set_shader_parameter("sphere_colours", colours ) 
		if emi_colours != null:
			material.set_shader_parameter("sphere_emissions", emi_colours)
		
		material.set_shader_parameter("sphere_count", len(objects))
		material.set_shader_parameter("object_count", len(objects))
		material.set_shader_parameter("max_bounce", bounces)
		material.set_shader_parameter("sphere_emission_strs", emi_strs)
		material.set_shader_parameter("num_ray_per_pix", num_ray_per_pix)
	
func set_active(active):
	calculate_properties()
	set_properties()
	is_active=active
	var viewport = get_editor_interface().get_editor_viewport_3d()
	#viewport.render_target_clear_mode=SubViewport.CLEAR_MODE_NEVER
	#viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	cam = viewport.get_camera_3d()
	overlay.material = material
	
	
		
	
	#for i in 20:
		#cam.set_cull_mask_value(i+1, !is_active)
	if !is_active:
		overlay.get_parent().remove_child(overlay)
	else:
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, overlay)
		var vsplit = overlay.get_parent()
		var editor_viewport = vsplit.get_child(0).get_child(0).get_child(0).get_child(0)
		vsplit.remove_child(overlay)
		overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
		editor_viewport.add_child(overlay)
		editor_viewport.move_child(overlay, 0)
		editor_viewport.print_tree_pretty()
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	#viewport.add_child(overlay)
	#overlay.owner=viewport
	
	#material.shader=shader
	
	#var rs = RenderingServer
	#render_quad = rs.instance_create()
	#rs.instance_set_base(render_quad, box_mesh)
	##rs.instance_geometry_set_material_override(render_quad, material)
	#rs.instance_set_scenario(render_quad, cam.get_world_3d().scenario)
	#var trans = Transform3D(Basis.IDENTITY, Vector3.ZERO)
	#rs.instance_set_transform(render_quad, cam.transform)
		
	#var tex = viewport.get_texture()
	#tex.draw()


func _exit_tree():
	remove_tool_menu_item("CamTest")
