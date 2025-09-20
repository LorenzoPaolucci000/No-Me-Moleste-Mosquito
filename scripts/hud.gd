extends Control

# UI nodes inside CanvasLayer
@onready var progress_bar: ProgressBar = $CanvasLayer/PollinationBar  
@onready var mission_label: Label = $CanvasLayer/MissionLabel

func _ready() -> void:
	# Initialize progress bar
	if progress_bar:
		progress_bar.min_value = 0
		progress_bar.max_value = 100
		progress_bar.value = 0
	
	# Hide mission label initially
	if mission_label:
		mission_label.visible = false

# Called by the player to update the pollination value (0..100)
func set_pollination(value: int) -> void:
	if not progress_bar:
		return
		
	var v = clamp(value, 0, 100)
	progress_bar.value = v
	
	# When pollination reaches 100, hide bar and show mission complete
	if v >= int(progress_bar.max_value):
		progress_bar.visible = false
		if mission_label:
			mission_label.visible = true
