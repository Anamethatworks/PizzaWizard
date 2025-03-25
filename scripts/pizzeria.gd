extends Area3D
class_name Pizzeria

## A static reference to the active pizzeria (assuming there's only one)
static var active_location: Pizzeria

## Is this location active (does it provide pizzas for the player to deliver?)
var is_active := false

## A queue of all pizzas at this location waiting to be picked up
var pizza_queue: Array[Pizza] = []

## How many pizzas can be queued at the pizzeria at once. If set to [code]0[/code],
## The location will be capable of storing an indefinite amount
const MAX_QUEUED_PIZZAS: int = 5

## Sets this location as active on ready
func _ready() -> void:
	set_active()	# TODO : Add support for multiple pizzerias

## Sets this pizzeria to the active location
func set_active() -> void:
	if is_instance_valid(active_location):
		active_location.is_active = false
	active_location = self
	is_active = true

## Creates and returns a new pizza at this location, ready to be picked up
func create_pizza() -> Pizza:
	assert((len(pizza_queue) <= MAX_QUEUED_PIZZAS) or (MAX_QUEUED_PIZZAS == 0), "Too many pizzas have been queued!")
	if (len(pizza_queue) == MAX_QUEUED_PIZZAS) and (MAX_QUEUED_PIZZAS > 0):
		return null # We are at the max, so don't create a new pizza
	
	var new_pizza := Pizza.new()
	pizza_queue.append(new_pizza)
	return new_pizza

## Gets the oldest pizza in the queue
## [param keep_in_queue]: If [code]true[/code], the pizza will be returned without
	## being removed from the queue
func get_pizza_from_queue(keep_in_queue: bool = false) -> Pizza:
	if len(pizza_queue) < 1:
		return null
	if not keep_in_queue:
		return pizza_queue.pop_front()
	return pizza_queue[0]

func _on_body_entered(body: Node3D) -> void:
	# Determine if the body is the player
	if body.name == "Player":
		@warning_ignore("integer_division")
		var n := int(Score.orders_completed / 2) + 1
		if n > 5:
			n = 5
		var num_orders = len(DeliveryManager.current_orders)
		if num_orders == 0:
			DeliveryManager.take_orders(n)
			var minimap_node = $"../../MiniMap"
			var ui_manager = $"../../UIPanel/UIManager"
			for i in range(0, len(DeliveryManager.current_orders)):
				minimap_node.call("add_delivery_icon", (DeliveryManager.current_orders[i].dropoffPoint.global_position))
				ui_manager.call("add_order_ticket", DeliveryManager.current_orders[i].parTime, DeliveryManager.current_orders[i].dropoffPoint.global_position)
		Score.earn_bonuses()
