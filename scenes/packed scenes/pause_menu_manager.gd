extends Control

@onready var fade_mask = $"FadeMask"
@onready var mask_anim = $"PauseMenuAnim"

var pause_active = false
var pause_lerp = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("Pause"):
		pause_active = !pause_active

	#when pause_active, increase lerp proportional to real time, use to lerp time_scale from 1.0 to 0.00001
	if pause_active:
		if pause_lerp < 1.0:
			pause_lerp += delta * 5 / Engine.time_scale
			if pause_lerp > 1.0:
				pause_lerp = 1.0
			Engine.time_scale = lerp(1.0, 0.00001, pause_lerp)
			fade_mask.modulate = Color(1, 1, 1, pause_lerp)

	#when !pause_active, decrease lerp proportional to real time, use to lerp time_scale to 1.0 from 0.00001
	else:
		if pause_lerp > 0.0:
			pause_lerp -= delta * 5 / Engine.time_scale
			if pause_lerp < 0.0:
				pause_lerp = 0.0
			Engine.time_scale = lerp(1.0, 0.00001, pause_lerp)
			fade_mask.modulate = Color(1, 1, 1, pause_lerp)

func _on_quit_game_pressed() -> void:
	pass # Replace with function body.

func _on_back_to_menu_pressed() -> void:
	pass # Replace with function body.

func _on_continue_pressed() -> void:
	pass # Replace with function body.
