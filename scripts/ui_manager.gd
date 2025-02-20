extends Node

@export var player : VehicleBody3D
@export var arrow : Node3D
@export var info_display : TextEdit
@export var order_list_display : GridContainer
var info_format_string = "Total Wallet: $%f\nAmbient Temperature: %d F\nCurrent Orders:"
var order_format_string = "%d.) Temp: %d F\n     Par Time: %ds\n     Time Since Order: %ds\n"

func _process(delta : float) -> void:
	# Format the info display
	info_display.text = info_format_string % [Money.player_gold, TempManager.amb_temp]
	
	# Clear the order list
	for child in order_list_display.get_children():
		child.free()
		
	# For the first 3 orders in [DeliveryManager.current_orders], display info
	var display_order : Label
	for i in len(DeliveryManager.current_orders):
		if i >= 3:
			break
		display_order = Label.new()
		order_list_display.add_child(display_order)
		display_order.text = order_format_string % [
			i + 1,
			DeliveryManager.current_orders[i].ordered_pizza.temperature,
			DeliveryManager.current_orders[i].parTime,
			DeliveryManager.current_orders[i].dropoffPoint.time_since_order
		]
		
	# Point the arrow at the target location
	arrow.position = player.position
	if DeliveryManager.current_orders.is_empty():
		arrow.visible = false
	else:
		if !arrow.visible:
			arrow.visible = true
		var target = DeliveryManager.current_orders[0].dropoffPoint.get_parent_node_3d().position
		arrow.look_at_from_position(
			Vector3(player.position.x, 0, player.position.z),
			Vector3(target.x, 0, target.z)
		)
	
