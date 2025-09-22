extends Node3D

# Reference to the flower's Area3D
@onready var area_3d = $Collector

# Flower state - becomes true after first pollination
var is_depleted: bool = false

func _ready():
	# Connect the Area3D body_entered signal
	if area_3d:
		area_3d.body_entered.connect(_on_body_entered)
		area_3d.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Check if the entering body is the player (mosquito)
	if body.is_in_group("player"):
		# Only give pollination if flower is not depleted
		if not is_depleted:
			body.increase_pollination()
			is_depleted = true  # Mark flower as used
			_update_flower_appearance()

func _on_body_exited(body):
	# Optional: handle when mosquito exits the flower
	if body.is_in_group("player"):
		pass  

# Visual feedback when flower becomes depleted
func _update_flower_appearance():
	# Make the flower darker/grayer to show it's used
	var mesh_instance = get_node_or_null("flower_A")
	if mesh_instance and mesh_instance is MeshInstance3D:
		# Create a new material instance to avoid affecting other flowers
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			material = material.duplicate()
		else:
			material = StandardMaterial3D.new()
		
		# Make the flower appear "used" (darker/grayer)
		material.albedo_color = material.albedo_color * 0.5  
		mesh_instance.set_surface_override_material(0, material)
