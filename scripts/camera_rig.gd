extends Node3D

#@onready var camera : SpringArm3D = get_child(0)
@onready var player : Node3D = $".."

## The vurrent building being cutout, if there is one
var cutout_building: Building

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = player.global_position
	global_rotation = Vector3.ZERO
	
	# Test if any buildings are obstructing our view
	if $Camera3D/RayCast3D.is_colliding():
		var collider: Building = $Camera3D/RayCast3D.get_collider().get_parent().get_parent().get_child(1)
		if is_instance_valid(cutout_building):
			if collider != cutout_building:
				cutout_building.end_cutout()
		collider.start_cutout()
		cutout_building = collider
	elif is_instance_valid(cutout_building):
		cutout_building.end_cutout()
		cutout_building = null
