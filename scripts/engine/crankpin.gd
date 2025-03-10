@tool class_name Crankpin extends Object
## Class for a single crankpin (the part of a crankshaft that pistons attach to)

var pistons: Array[Piston] = []

func _init(piston_list: Array[Piston]) -> void:
	pistons = piston_list
