extends Node3D

@export var look_sens := 0.14
@export var move_speed := 8.0
@export var sprint_mult := 2.5
@export var accel := 12.0
@export var pitch_limit := 1.35

var cam: Camera3D
var pitch := 0.0
var vel := Vector3.ZERO

func _ready():
	cam = Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 1.6, 0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_unhandled_input(true)

func _unhandled_input(e):
	if e is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-deg_to_rad(e.relative.x * look_sens))
		pitch = clamp(pitch - deg_to_rad(e.relative.y * look_sens), -pitch_limit, pitch_limit)
		cam.rotation.x = pitch
	if e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if e is InputEventMouseButton and e.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(dt):
	var x := Input.get_axis("ui_left", "ui_right")
	var z := Input.get_axis("ui_up", "ui_down") * -1.0
	var y := 0.0
	if Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_page_up"):
		y += 1.0
	if Input.is_key_pressed(KEY_CTRL) or Input.is_action_pressed("ui_page_down"):
		y -= 1.0
	var speed := move_speed * (sprint_mult if Input.is_key_pressed(KEY_SHIFT) else 1.0)

	var fwd := -global_transform.basis.z
	var right := global_transform.basis.x
	var up := Vector3.UP
	var wish := (right * x + fwd * z + up * y).normalized() * speed
	vel = vel.lerp(wish, clamp(accel * dt, 0.0, 1.0))
	global_position += vel * dt
