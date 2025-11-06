extends Node3D

@export var quad : MeshInstance3D
@export var trg : Node3D
@export var matty : Transform3D
@export var projjy : Projection
var shadmat : ShaderMaterial

var viewport 
var cam : Camera3D

func _ready():
	viewport = get_viewport()
	shadmat = quad.get_active_material(0) as ShaderMaterial
	cam = $Camera3D

func _process(_delta):
	if shadmat!=null && cam !=null:
		var size = DisplayServer.window_get_size()
		var near = $Camera3D.near
		var plane_height = near * tan( deg_to_rad($Camera3D.fov * 0.5 )) * 2
		var aspect = size.aspect()
		var plane_width = plane_height * aspect
		var view_params = Vector3(plane_width, plane_height, near)
		var glob_pos = ($Camera3D as Camera3D).get_global_position()
		var mat = ($Camera3D as Camera3D).transform
		matty = mat.affine_inverse()
		var proj = Projection(mat.affine_inverse())
		proj.x.w = ($Camera3D as Camera3D).global_position.x
		proj.y.w = ($Camera3D as Camera3D).global_position.y
		proj.z.w = ($Camera3D as Camera3D).global_position.z 
		proj.w = Vector4.ZERO
		projjy = proj
		
		shadmat.set_shader_parameter("frustrum_info",Plane(view_params)) 
		shadmat.set_shader_parameter("cam_local_world", proj)
		shadmat.set_shader_parameter("world_space_camera_pos", Plane(glob_pos))
		shadmat.set_shader_parameter("screen_pixel_size", Vector2(size.x,size.y)) 
