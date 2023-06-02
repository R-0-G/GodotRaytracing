extends Node

# https://www.youtube.com/watch?v=Qz0KTGYJtUk

@export var debug_point_count : Vector2i = Vector2i(16,16)
@export var camera_arrow : PackedScene

var arrow_dict : Dictionary

func test(p):
	if $Camera3D==null:
		return
	var plane_height = $Camera3D.near * tan( deg_to_rad($Camera3D.fov * 0.5 )) * 2
	var aspect = DisplayServer.window_get_size().aspect()
	var plane_width = plane_height * aspect
	
	var bottom_left_local = Vector3(-plane_width / 2, -plane_height/2, $Camera3D.near)
	
	for x in debug_point_count.x:
		for y in debug_point_count.y:
			var tx = (x as float) / ((debug_point_count.x-1) as float)
			var ty = (y as float) / ((debug_point_count.y-1) as float)
			
			var point_local = bottom_left_local + Vector3(plane_width * tx, plane_height * ty, 0)
			var point = $Camera3D.position + $Camera3D.basis.x * point_local.x +  $Camera3D.basis.y * point_local.y +  -$Camera3D.basis.z * point_local.z
			var vec = Vector2i(x,y)
			
			draw_point(vec,point)
# Called when the node enters the scene tree for the first time.
func draw_point(vec,point):
	if !arrow_dict.has(vec):
		var arr =camera_arrow.instantiate()
		arrow_dict[vec] = arr
		var cam = $Camera3D
#		print(cam, " ", arr)
#		cam.add_child(arr)
	arrow_dict[vec].position = point
			
func _ready():
	test(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test(false)
