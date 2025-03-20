extends Object
class_name DeliveryManager

## An array of all [DropoffPoint]s without an associated order
static var available_dropoff_points : Array[DropoffPoint] = []

## An array of [Order]s currently unfulfilled
static var current_orders : Array[Order] = []

## Adds a [DropoffPoint] to [dropoffPoints]
static func addDropoffPoint(point : DropoffPoint) -> void:
	available_dropoff_points.append(point)

## Ranks orders based on how close they are to their [parTime]s
static func rank_orders() -> void:
	var reordered : Array[Order] = []
	var top : int
	var top_time_to_par : float
	var time_to_par : float
	while !current_orders.is_empty():
		top = 0
		top_time_to_par = current_orders[top].parTime - current_orders[top].dropoffPoint.time_since_order
		for i in range(len(current_orders)):
			time_to_par = current_orders[i].parTime - current_orders[i].dropoffPoint.time_since_order
			if time_to_par < top_time_to_par:
				top = i
				top_time_to_par = time_to_par
		reordered.append(current_orders.pop_at(top))
	current_orders = reordered

## Creates a number of [Order]s randomly at various [DropoffPoint]s in [dropoffPoints]
static func take_orders(number: int) -> void:
	var dropoffs : int
	var index : int
	var new_order : Order
	for i in range(number):
		dropoffs = len(available_dropoff_points)
		if dropoffs == 0:
			break
		index = randi_range(0, dropoffs - 1)
		new_order = available_dropoff_points[index].add_order()
		if new_order:
			available_dropoff_points.pop_at(index)
			current_orders.append(new_order)
			#MinimapManager.add_delivery_icon(new_order.dropoffPoint.global_position)
	rank_orders()

## Removes an [Order] from the array of [current_orders] and destroys it
static func finish_order(order: Order) -> void:
	if order in current_orders:
		available_dropoff_points.append(order.dropoffPoint)
		#MinimapManager.remove_delivery_icon(order.dropoffPoint.global)
		order.ordered_pizza.free()
		current_orders.erase(order)
		order.call_deferred("free")
	rank_orders()

## Clears all [Order]s and [DropoffPoint]s from their respective arrays
## Needed this to avoid orders breaking since the city in the main menu populates the arrays with references that are later null
static func clear_orders() -> void:
	available_dropoff_points.clear()
	current_orders.clear()