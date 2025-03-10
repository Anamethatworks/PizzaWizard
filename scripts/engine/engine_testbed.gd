@tool extends Control
## Utility class for testing engines. Should not be used in the final project.
## If you want to do something with an engine, use the Engine class instead!
## This is only for debugging engines

@export_tool_button("Reload Engine", "Callable") var reload_button: Callable = reload_engine

func reload_engine() -> void:
	pass
