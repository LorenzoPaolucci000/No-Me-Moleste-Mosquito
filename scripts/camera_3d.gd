extends Camera3D

@export var target: Node3D 
@export var offset := Vector3(0, 2, -6)
@export var follow_speed := 30.0 

func _process(delta):
	if target:
		var desired_position = target.global_transform.origin + target.global_transform.basis * offset
		global_transform.origin = lerp(global_transform.origin, desired_position, delta * follow_speed)
		look_at(target.global_transform.origin, Vector3.UP)
