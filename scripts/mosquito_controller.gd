extends CharacterBody3D

# -------------------------
# MOVEMENT VARIABLES
# -------------------------
@export var walk_speed: float = 5.0
@export var gravity: float = 13
@export var rotation_speed: float = 10.0

# -------------------------
# FLIGHT VARIABLES
# -------------------------
@export var flight_speed: float = 7.0
@export var mouse_sensibility: float = 35.0
var mouse_movement: Vector2 = Vector2.ZERO

# -------------------------
# HUD VARIABLES
# -------------------------
@export var hud_path: NodePath
var hud = null
var current_pollination: int = 0

# -------------------------
# ANIMATION NODES
# -------------------------
@onready var animation_player = $Sketchfab_Scene/AnimationPlayer
@onready var model = $Sketchfab_Scene

# -------------------------
# STATE VARIABLES
# -------------------------
var is_walking: bool = false
var is_flying: bool = false

# Start function
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	
	# Connect HUD
	if hud_path and str(hud_path) != "":
		hud = get_node_or_null(hud_path)
	else:
		hud = get_node_or_null("../HUD")

# Handle input (mouse motion and flight toggle)
func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
	if Input.is_action_just_pressed("toggle_flight"):
		is_flying = !is_flying
		if is_flying:
			velocity.y = 0.0
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Main physics loop
func _physics_process(delta):
	if is_flying:
		handle_flight(delta)
	else:
		handle_movement(delta)
		handle_gravity(delta)
	handle_animations()
	move_and_slide()

# -------------------------
# WALKING SYSTEM
# -------------------------
# Handle walking movement and rotation
func handle_movement(delta):
	var input_dir = Vector3.ZERO
	
	# WASD movement directions
	if Input.is_action_pressed("move_forward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_left"):
		input_dir.x += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x -= 1

	# Mouse rotation (only yaw, no pitch/roll while walking)
	if mouse_movement != Vector2.ZERO:
		rotation.y -= (mouse_movement.x / mouse_sensibility) * delta
		mouse_movement = Vector2.ZERO

	# If there is input, move relative to orientation
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		is_walking = true

		# Convert local input into global direction based on rotation
		var direction = (transform.basis * input_dir).normalized()

		# Apply walking speed
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		is_walking = false
		# Smoothly decelerate when no input is given
		velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)

# Apply gravity if not standing on the floor
func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

# Handle animations depending on movement state
func handle_animations():
	if animation_player:
		if is_flying:
			if animation_player.current_animation != "fly":
				animation_player.play("fly")
		elif is_walking and is_on_floor():
			if animation_player.current_animation != "bite":
				animation_player.play("bite")
		elif not is_on_floor():
			if animation_player.current_animation != "fly":
				animation_player.play("fly")

# -------------------------
# FLIGHT SYSTEM
# -------------------------
# Handle flying movement and rotations
func handle_flight(delta):
	var input_dir = Vector3.ZERO

	# Forward / backward (W/S)
	if Input.is_action_pressed("move_forward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z -= 1
	
	# Vertical movement (Q/E)
	if Input.is_action_pressed("move_up"):
		input_dir.y += 1
	if Input.is_action_pressed("move_down"):
		input_dir.y -= 2

	# Normalize and apply flight speed
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		velocity = (global_transform.basis * input_dir) * flight_speed
	else:
		velocity = Vector3.ZERO
	
	# Apply small gravity pull to flight
	velocity.y -= gravity * delta

	# Mouse rotations
	if mouse_movement != Vector2.ZERO:
		# Yaw (mouse X)
		rotation.y -= (mouse_movement.x / mouse_sensibility) * delta
		# Pitch (mouse Y)
		rotation.x -= (mouse_movement.y / mouse_sensibility) * delta
		mouse_movement = Vector2.ZERO

	# Roll with keyboard (A/D)
	if Input.is_action_pressed("move_right"):
		rotation.z += 1 * delta
	if Input.is_action_pressed("move_left"):
		rotation.z -= 1 * delta

# -------------------------
# POLLINATION SYSTEM
# -------------------------
# Increase pollination when entering flower area
func increase_pollination():
	current_pollination += 15
	current_pollination = clamp(current_pollination, 0, 100)
	
	# Update HUD
	if hud and hud.has_method("set_pollination"):
		hud.set_pollination(current_pollination)
