extends Node3D

#@export var shader : Shader 
@export var tex_rect : TextureRect
@export var trg : Node3D
@export var matty : Transform3D
@export var projjy : Projection
var shadmat : ShaderMaterial

var viewport 
var cam : Camera3D
#var mat : ShaderMaterial

func _ready():
	viewport = get_viewport()
	shadmat = (tex_rect.material as ShaderMaterial)
	cam = $Camera3D

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
#	print(fmod(t,2)/2)
#	shadmat
	if shadmat!=null && cam !=null:
		var size = DisplayServer.window_get_size()
		#var near_plane =  cam.get_frustum()[0]
		var near = $Camera3D.near
		var plane_height = near * tan( deg_to_rad($Camera3D.fov * 0.5 )) * 2
		var aspect = DisplayServer.window_get_size().aspect()
		var plane_width = plane_height * aspect
		var view_params = Vector3(plane_width, plane_height, near)
#		print(view_params)
		var glob_pos = ($Camera3D as Camera3D).get_global_position()
		var mat = ($Camera3D as Camera3D).transform
		matty = mat.affine_inverse()
		var proj = Projection(mat.affine_inverse())
		proj.x.w = ($Camera3D as Camera3D).global_position.x
		proj.y.w = ($Camera3D as Camera3D).global_position.y
		proj.z.w = ($Camera3D as Camera3D).global_position.z #crap that i have to do this
		proj.w = Vector4.ZERO
		projjy = proj
#		
		var vp = Vector4(0.0,0.0,1.0, 1.0)
		var vpg = vp*proj
		#print(vpg, " : ", Vector3(vpg.x, vpg.y, vpg.z)- glob_pos)
		
		shadmat.set_shader_parameter("viewParams",Plane(view_params)) #crap that i have to do this
		shadmat.set_shader_parameter("cam_local_world", proj)
		shadmat.set_shader_parameter("world_space_camera_pos", Plane(glob_pos)) #crap that i have to do this
		
#	print(shadmat.get_shader_parameter("time"))
#	shader.set set_uniform("time", )
	# Update the viewport and canvas layer
#	viewport.update()
#	viewport.render_target.clear_color = Color(0, 0, 0)
#	viewport.render_target.clear()
#	viewport.render_tree()
