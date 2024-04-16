@tool
extends EditorPlugin

var box_instance
@onready var box_mesh = BoxMesh.new()

var but : MenuButton
func _enter_tree():
	add_tool_menu_item("CameraTest", cam_test)
	
func cam_test():
	var viewport = get_editor_interface().get_editor_viewport_3d()
	if viewport.get_camera_3d().fov == 90:
		viewport.get_camera_3d().fov = 70
	else:
		viewport.get_camera_3d().fov = 90
	
	var rs = RenderingServer
	box_instance = rs.instance_create()
	rs.instance_set_base(box_instance, box_mesh)
	rs.instance_set_scenario(box_instance, viewport.get_camera_3d().get_world_3d().scenario)
	var trans = Transform3D(Basis.IDENTITY, Vector3.ZERO)
	rs.instance_set_transform(box_instance, trans)
		
	#var tex = viewport.get_texture()
	#tex.draw()


func _exit_tree():
	remove_tool_menu_item("CamTest")
