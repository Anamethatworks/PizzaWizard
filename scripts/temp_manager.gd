extends Node
class_name TempManager

## The parent node to the node containing the temperature manager, provides
## the position the ambient temperature is measured at
static var parent : Node3D

## The ambient temperature at the [parent]'s location
static var amb_temp : float

func _ready() -> void:
	parent = self.get_parent()

## Decreases pizza temperature of all existing orders in [current_orders]
func _process(delta: float) -> void:
	#amb_temp = get_ambient_temperature(parent.position, parent.get_world_3d())
	amb_temp = get_zone_temp()
	for order in DeliveryManager.current_orders:
		order.ordered_pizza.process_temperature(amb_temp, delta)

## Gets ambient temperature of surrounding atmosphere
static func get_ambient_temperature(pos: Vector3, world_3d: World3D) -> float:
	var params := PhysicsPointQueryParameters3D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.position = pos
	var intersections : Array[Dictionary] = world_3d.direct_space_state.intersect_point(params)
	for intersection in intersections:
		var got_temp = instance_from_id(intersection["collider_id"]).get("ambient_temperature")
		if got_temp:
			print(got_temp)
			return got_temp
	return 72.0
	
func get_zone_temp():
	#print("cehck")
	return parent.CurrentTempZone
