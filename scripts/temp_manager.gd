extends Node
class_name TempManager

var player : CharacterBody3D

func _ready() -> void:
	player = self.get_parent()

## Decreases pizza temperature of all existing orders in [current_orders]
func _process(delta: float) -> void:
	for order in DeliveryManager.current_orders:
		var amb_temp : float = get_ambient_temperature(player.position, player.get_world_3d())
		print(amb_temp)
		order.ordered_pizza.process_temperature(amb_temp, delta)

## Gets ambient temperature of surrounding atmosphere
static func get_ambient_temperature(pos: Vector3, world_3d: World3D) -> float:
	var params := PhysicsPointQueryParameters3D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.position = pos
	var intersections : Array[Dictionary] = world_3d.direct_space_state.intersect_point(params)
	for intersection in intersections:
		var amb_temp = instance_from_id(intersection["collider_id"]).get("ambient_temperature")
		if amb_temp:
			return amb_temp
	return 72.0
