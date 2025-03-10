@tool class_name Piston extends Object
## Class for simulating a piston and cylinder in an engine

var angle: float


func _init(theta: float = 0.0) -> void:
	angle = theta
