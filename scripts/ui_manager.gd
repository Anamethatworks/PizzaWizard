extends Node

var MAX_DISPLAY_ORDERS = 4

var player : VehicleBody3D
var info_display : TextEdit

var order_list_display : GridContainer
var info_format_string = "Total Wallet: $%.*f\nAmbient Temperature: %d° F\nCurrent Orders:"
var order_format_string = "%d.) Temp: %d° F\n     Par Time: %ds\n     Time Since Order: %ds\n"

func _ready() -> void:
	player = $"../../Player"
	info_display = $"../InfoDisplay"
	order_list_display = $"../OrderList"

func _process(delta : float) -> void:
	# Format the info display
	info_display.text = info_format_string % [
		2,	# pad to 2 decimal places 
		Money.player_gold,
		TempManager.amb_temp
	]
	
	# Clear the order list
	for child in order_list_display.get_children():
		child.free()
		
	# For the first 3 orders in [DeliveryManager.current_orders], display info
	var display_order : Label
	for i in len(DeliveryManager.current_orders):
		if i >= MAX_DISPLAY_ORDERS:
			break
		display_order = Label.new()
		order_list_display.add_child(display_order)
		display_order.text = order_format_string % [
			i + 1,
			DeliveryManager.current_orders[i].ordered_pizza.temperature,
			DeliveryManager.current_orders[i].parTime,
			DeliveryManager.current_orders[i].dropoffPoint.time_since_order
		]
