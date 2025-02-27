extends Node3D

@onready var camera : Camera3D = get_child(0)
@onready var player : Node3D = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = player.global_position
	global_rotation = Vector3.ZERO
