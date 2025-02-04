extends Node
class_name DeliveryManager

## An array of [DropoffPoint]s set in the editor
@export var dropoffPoints := []

## An array of [Order]s currently unfulfilled
static var current_orders := []

func _ready() -> void:
	take_orders(1) # For Testing

func _process(delta: float) -> void:
	pass

## Creates a number of [Order]s randomly at various [DropoffPoint]s in [dropoffPoints]
func take_orders(number: int) -> void:
	for i in range(number):
		var dropoffs = len(dropoffPoints)
		var new_order
		while true:
			new_order = dropoffPoints[randi_range(0, dropoffs)].add_order()
			if new_order != null:
				break
		current_orders.append(new_order)

## Removes an [Order] from the array of [current_orders]
static func finish_order(order: Order) -> void:
	if order in current_orders:
		current_orders.erase(order)