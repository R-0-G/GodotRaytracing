@tool
extends EditorPlugin

var box_instance
@onready var box_mesh = BoxMesh.new()

var but : MenuButton
func _enter_tree():
	but = MenuButton.new()
	var pop = but.get_popup()
	
	pop.add_item("Add Cube")
	pop.add_item("Add Sphere")
	pop.add_item("Add Null")
	
	pop.id_pressed.connect(add_primitive)
	but.text = "AddGd"
	but.toggle_mode=true
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, but)
	
	

	
func add_primitive(i):
	if i==0:
		add_cube()
	else:
		add_sphere()
	
func add_cube(): 
	add_mesh( BoxMesh.new(), "Cube")
	
func add_sphere(): 
	add_mesh( SphereMesh.new(), "Sphere")
	
	
func add_mesh(mesh, inst_name):
	var current = get_tree().edited_scene_root
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name=inst_name+str(current.get_child_count())
	current.add_child(mesh_inst)
	mesh_inst.owner=current
	mesh_inst.mesh = mesh
	

func _exit_tree():
	pass
	
