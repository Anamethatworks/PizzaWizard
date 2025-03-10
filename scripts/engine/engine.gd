@tool class_name VehicleEngine extends Node
## Class to simulate the inner workings of an engine

@export var specs: EngineSpecs
@export_tool_button("Update", "Callable") var update_button: Callable = update_setup

var crankshaft: Crankshaft

func update_setup() -> void:
	if specs:
		crankshaft = specs.setup_general()
