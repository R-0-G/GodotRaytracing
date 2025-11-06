extends Node3D

@export var quad : MeshInstance3D
var shadmat : ShaderMaterial
@onready var cam : Camera3D = $Camera3D

func _ready():
	shadmat = quad.get_active_material(0) as ShaderMaterial

func _process(_delta):
	if shadmat!=null && cam !=null:
		var size = DisplayServer.window_get_size()
		var near = cam.near
		var plane_height = near * tan( deg_to_rad(cam.fov * 0.5 )) * 2
		var aspect = size.aspect()
		var plane_width = plane_height * aspect
		var view_params = Vector3(plane_width, plane_height, near)
		var glob_pos = cam.get_global_position()
		var mat = cam.transform
		var proj = Projection(mat.affine_inverse())
		proj.x.w = cam.global_position.x
		proj.y.w = cam.global_position.y
		proj.z.w = cam.global_position.z 
		proj.w = Vector4.ZERO
		
		shadmat.set_shader_parameter("frustrum_info",Plane(view_params)) 
		shadmat.set_shader_parameter("cam_local_world", proj)
		shadmat.set_shader_parameter("world_space_camera_pos", Plane(glob_pos))
		shadmat.set_shader_parameter("screen_pixel_size", Vector2(size.x,size.y)) 
