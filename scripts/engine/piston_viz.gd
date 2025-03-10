@tool extends Control
## A visualizer for a single piston

var piston: Piston


func _init(pist: Piston) -> void:
	piston = pist

func _process(delta: float) -> void:
	if piston:
