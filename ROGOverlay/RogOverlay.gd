@tool
extends EditorPlugin

@onready var overlay = ColorRect.new()
@onready var material = preload("res://addons/ROGodot/ROGOverlay/CanvasOverlayMaterial.tres")
@onready var mat = preload("res://funmat.tres")

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
		if tex!=null:
			mat.albedo_texture = tex
			material.set_shader_parameter("last_tex", tex)
		
		material.set_shader_parameter("cam_forward", cam.basis.z )
		material.set_shader_parameter("cam_pos", cam.position )
		material.set_shader_parameter("cam_fov", cam.fov )
		material.set_shader_parameter("cam_near", cam.near )
		material.set_shader_parameter("cam_far", cam.far )
		#tex=cam.get_viewport().get_texture()
		var img = overlay.get_viewport().get_texture().get_image()
		tex = ImageTexture.create_from_image(img)
		
		#https://github.com/godotengine/godot/pull/79288
		#var rd = RenderingServer.get_rendering_device()
		#var root = get_tree().edited_scene_root
		#var tex_data = rd.texture_get_data()
		#print(root.name + "rt")
		#var current = root.get_child(0) as MeshInstance3D
		#print(current.name)
		#var mat = current.get_surface_override_material(0) as StandardMaterial3D
	


	
func set_active(active):
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
