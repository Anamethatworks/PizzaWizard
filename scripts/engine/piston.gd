@tool class_name Piston extends Object
## Class for simulating a piston and cylinder in an engine

enum {TWO_STROKE=2, FOUR_STROKE=4}

var angle: float
var rod_length: float



func _init(theta: float = 0.0, connecting_rod_length: float = 0.0) -> void:
	angle = theta
	rod_length = connecting_rod_length
