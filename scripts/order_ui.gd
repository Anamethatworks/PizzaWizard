extends Node

var pos = Vector3()

@onready var time_label = %TimeText
@onready var par_label = %ParText
@onready var temp_label = %TempText

func set_par_time(time: int) -> void:
	if (par_label):
		par_label.text = str(time) + "s"

func update_time_label(time: float) -> void:
	if (time_label):
		time_label.text = str(int(time)) + "s"

func update_temp_label(new_temp: int) -> void:
	if (temp_label):
		temp_label.text = str(new_temp) + "°"

func random_rotate() -> void:
	%OrderPanel.rotation_degrees = randf_range(-5.0, 5.0)
