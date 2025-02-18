extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3d

var SPEED = 5

func _physics_process(delta: float) -> void:
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

func update_target_location(target_location):
	pass
	nav_agent.target_position = target_location
