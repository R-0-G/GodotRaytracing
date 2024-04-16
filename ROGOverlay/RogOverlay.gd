@tool
extends EditorPlugin

var render_quad
@onready var overlay = ColorRect.new()
@onready var box_mesh = QuadMesh.new()
#@onready var material = ShaderMaterial.new()
#@onready var shader = preload("res://addons/ROGodot/ROGOverlay/Overlay.gdshader")


var but : MenuButton
func _enter_tree():
	add_tool_menu_item("CameraTest", cam_test)
	
func cam_test():
	var viewport = get_editor_interface().get_editor_viewport_3d()
	var cam = viewport.get_camera_3d()
	
	#material.shader=shader
	
	var rs = RenderingServer
	render_quad = rs.instance_create()
	rs.instance_set_base(render_quad, box_mesh)
	#rs.instance_geometry_set_material_override(render_quad, material)
	rs.instance_set_scenario(render_quad, cam.get_world_3d().scenario)
	var trans = Transform3D(Basis.IDENTITY, Vector3.ZERO)
	rs.instance_set_transform(render_quad, cam.transform)
		
	#var tex = viewport.get_texture()
	#tex.draw()


func _exit_tree():
	remove_tool_menu_item("CamTest")
