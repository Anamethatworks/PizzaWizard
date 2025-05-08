extends Node3D

var player : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = player.global_position
	var target = Pizzeria.active_location.global_position
	if !DeliveryManager.current_orders.is_empty():
		target = DeliveryManager.current_orders[0].dropoffPoint.global_position
	look_at(Vector3(target.x, player.global_position.y, target.z))
