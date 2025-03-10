@tool class_name Crankshaft extends Object

var crankpins: Array[Crankpin] = []

func _init(crankpin_list: Array[Crankpin]) -> void:
	crankpins = crankpin_list
