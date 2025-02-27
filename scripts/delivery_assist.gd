extends Node3D

var player : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = player.global_position
	var target = Pizzeria.active_location.global_position
	if !DeliveryManager.current_orders.is_empty():
		target = DeliveryManager.current_orders[0].dropoffPoint.global_position
	look_at_from_position(
			Vector3(player.position.x, 0, player.position.z),
			Vector3(target.x, 0, target.z)
		)
