extends CharacterBody3D

# Movement Variables
@export var walk_speed: float = 5.0
@export var gravity: float = 9.8
@export var rotation_speed: float = 10.0

# AnimationPlayer Paths
@onready var animation_player = $Sketchfab_Scene/AnimationPlayer
@onready var model = $Sketchfab_Scene

# State Variables
var is_walking: bool = false

func _ready():
	print("Mosquito is ready")


func _physics_process(delta):
	handle_movement(delta)
	handle_gravity(delta)
	handle_animations()
	move_and_slide()

func handle_movement(delta):
	# Reset input value
	var input_dir = Vector3.ZERO
	
	# Input WASD or Arrows
	if Input.is_action_pressed("move_forward") or Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward") or Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	
	
	# Check if it is moving
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		is_walking = true
		
		# Rotate the Mosquito direction
		var target_rotation = atan2(input_dir.x, input_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
		
		# Apply walk speed
		velocity.x = input_dir.x * walk_speed
		velocity.z = input_dir.z * walk_speed
	else:
		is_walking = false
		# Stop movement
		velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)

# Apply gravity if Mosquito is not on the floor
func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

# Handle animations based on Mosquito actions
func handle_animations():
	if animation_player:
		if is_walking and is_on_floor():
			if animation_player.current_animation != "bite":
				animation_player.play("bite")
