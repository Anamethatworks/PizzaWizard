extends Object
class_name DeliveryManager

## An array of [DropoffPoint]s set in the editor
static var dropoffPoints : Array[DropoffPoint] = []

## An array of [Order]s currently unfulfilled
static var current_orders : Array[Order] = []

## Adds a [DropoffPoint] to [dropoffPoints]
static func addDropoffPoint(point : DropoffPoint) -> void:
	dropoffPoints.append(point)

## Creates a number of [Order]s randomly at various [DropoffPoint]s in [dropoffPoints]
static func take_orders(number: int) -> void:
	for i in range(number):
		var dropoffs = len(dropoffPoints)
		if dropoffs == 0:
			break
			
		var index
		var new_order
		while true:
			index = randi_range(0, dropoffs - 1)
			new_order = dropoffPoints[index].add_order()
			if new_order != null:
				break
		dropoffPoints.pop_at(index)
		current_orders.append(new_order)
		print("Pizza picked up!")

## Removes an [Order] from the array of [current_orders]
static func finish_order(order: Order) -> void:
	if order in current_orders:
		dropoffPoints.append(order.dropoffPoint)
		current_orders.erase(order)
		order.call_deferred("free")
	print("Pizza delivered!")
