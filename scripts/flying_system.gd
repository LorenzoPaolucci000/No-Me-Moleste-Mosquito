extends RigidBody3D

@export var throttle = 1
@export var mouse_sensibility = 30
var mouse_movement = Vector2()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		throttle = 1.5
	elif Input.is_action_pressed("move_down"):
		throttle = 0.5
	else:
		throttle = 1

	apply_central_force(global_transform.basis * (Vector3.UP * 9.8 * throttle))

	# Torque
	if mouse_movement != Vector2.ZERO:
		# Yaw (mouse X)
		apply_torque(global_transform.basis * Vector3.DOWN * (mouse_movement.x / mouse_sensibility))
		# Pitch (mouse Y)
		apply_torque(global_transform.basis * Vector3.LEFT * (mouse_movement.y / mouse_sensibility))
		mouse_movement = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		apply_torque(global_transform.basis * Vector3.BACK / 5)
	if Input.is_action_pressed("move_left"):
		apply_torque(global_transform.basis * Vector3.FORWARD / 5)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement += event.relative
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
