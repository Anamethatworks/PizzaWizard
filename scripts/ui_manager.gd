extends Node

var MAX_DISPLAY_ORDERS = 4

var player : VehicleBody3D
var info_display : TextEdit

var order_list_display : GridContainer
var info_format_string = "Total Wallet: $%.*f\nAmbient Temperature: %d° F\nCurrent Orders:"
var order_format_string = "%d.) Temp: %d° F\n     Par Time: %ds\n     Time Since Order: %ds\n"

var display_gold = 0
var display_temp = 73
@onready var amb_temp_label = $"../TempLabel"
@onready var player_wallet_label = $"../WalletLabel"
@onready var order_ticket_holder = $"../HBoxContainer"
var order_ticket_scene = preload("res://scenes/packed scenes/order_control.tscn")
var order_tickets = []

func _ready() -> void:
	player = $"../../Player"
	info_display = $"../InfoDisplay"
	order_list_display = $"../OrderList"


func _process(delta : float) -> void:

	#if display_temp isn't equal to amb_temp, lerp display_temp and display value
	if (display_temp != TempManager.amb_temp):
		display_temp = lerp(float(display_temp), float(TempManager.amb_temp), 0.1)
		if (abs(display_temp - TempManager.amb_temp) < 0.5):
			display_temp = TempManager.amb_temp
		amb_temp_label.text = str(int(display_temp)) + "°"

	#if display gold isn't equal to player_gold, lerp display_gold and display value
	if (display_gold != Money.player_gold):
		display_gold = lerp(float(display_gold), float(Money.player_gold), 0.1)
		if (abs(display_gold - Money.player_gold) < 0.5):
			display_gold = Money.player_gold
		#var new_wallet_val = float(int(display_gold * 100)) / 100.0 #converted to cents but goes over text box length
		var new_wallet_val = int(display_gold)
		player_wallet_label.text = "[center]$" + str(new_wallet_val) + "[/center]"
	
	#Update time and temp of individual orders
	for i in range(0, len(order_tickets)):
		order_tickets[i].update_temp_label(DeliveryManager.current_orders[i].ordered_pizza.temperature)
		order_tickets[i].update_time_label(DeliveryManager.current_orders[i].dropoffPoint.time_since_order)

func add_order_ticket(par: int, pos: Vector3) -> void:
	var new_ticket = order_ticket_scene.instantiate()
	new_ticket.call_deferred("random_rotate")
	new_ticket.pos = pos
	new_ticket.call_deferred("set_par_time", par)
	order_ticket_holder.add_child(new_ticket)
	order_tickets.append(new_ticket)

func remove_order_ticket(pos: Vector3) -> void:
	for i in range(0, len(order_tickets)):
		if order_tickets[i].pos == pos:
			var popped_ticket = order_tickets.pop_at(i)
			popped_ticket.queue_free()
			break

func clear_order_tickets() -> void:
	for i in range(0, len(order_tickets)):
		order_tickets[i].queue_free()
	order_tickets = []
