extends Control

@onready var minmap_icon_mask = $"MinMapIconMask"
@onready var pizzeria_pos = $"MinMapIconMask/PizzeriaPos"
@onready var minimap_pos = $"MinMapRoundMask/MinMapRound"
@onready var player_icon = $"MinMapIconMask/PlayerPos"
@onready var player = $"../Player"
var delivery_icon_scene = preload("res://scenes/deliver_pos.tscn")

var pizzeria_location = Vector3(12.63, 0, -4.24)

var minimap_offset = Vector2(-286, -388)
var pizzeria_offset = Vector2(64, 91)
var map_to_world_ratio = 1.64

var deliver_locations : Array[Vector3] = []
var delivery_icons : Array[Control] = []

func add_delivery_icon(loc: Vector3) -> void:
	#print("Adding delivery to " + str(len(deliver_locations)) + "total delivery locations")
	deliver_locations.append(loc)
	var new_icon = delivery_icon_scene.instantiate()
	minmap_icon_mask.add_child(new_icon)
	delivery_icons.append(new_icon)
	

func remove_delivery_icon(loc: Vector3) -> void:
	#print("Removing delivery from " + str(len(deliver_locations)) + "total delivery locations")
	for i in range(len(deliver_locations)):
		#print (len(deliver_locations))
		if deliver_locations[i] == loc:
			#print("found location, should be deleting it")
			deliver_locations.remove_at(i)
			var icon = delivery_icons.pop_at(i)
			icon.queue_free()
			minmap_icon_mask.remove_child(icon)
			break

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Maps UI positions in general to match game world positions
	var map_x = player.position.x * map_to_world_ratio
	var map_y = player.position.z * map_to_world_ratio

	#Maps minimap position to match game world positions
	minimap_pos.set_position(Vector2(minimap_offset.x + map_x, minimap_offset.y + map_y))
	
	#Maps pizzeria icon to match game world position
	var piz_x = (player.position.x - pizzeria_location.x) * map_to_world_ratio
	var piz_y = (player.position.z - pizzeria_location.z) * map_to_world_ratio
	var piz_pos = Vector2(pizzeria_offset.x + piz_x, pizzeria_offset.y + piz_y)
	if (Vector2(piz_x, piz_y).length() > 90):
		var dir = Vector2(player.position.x - pizzeria_location.x, player.position.z - pizzeria_location.z)
		var angle = atan2(dir.y, dir.x)
		var new_x = cos(angle) * 80
		var new_y = sin(angle) * 80
		pizzeria_pos.set_position(Vector2(84 + new_x, 84 + new_y))
	else:
		pizzeria_pos.set_position(Vector2(pizzeria_offset.x + map_x, pizzeria_offset.y + map_y))
	
	#rotates player icon on minimap
	player_icon.rotation = -player.rotation.y
	
	#Maps delivery icons to match game world position
	for i in range(0, len(delivery_icons)):
		var del_x = (player.position.x - deliver_locations[i].x) * map_to_world_ratio
		var del_y = (player.position.z - deliver_locations[i].z) * map_to_world_ratio
		var del_pos = Vector2(89 + del_x, 69 + del_y)
		if (Vector2((89 + del_x) - 100,(69 + del_y) - 100).length() > 90):
			var dir = Vector2(player.position.x - deliver_locations[i].x, player.position.z - deliver_locations[i].z)
			var angle = atan2(dir.y, dir.x)
			var new_x = cos(angle) * 80
			var new_y = sin(angle) * 80
			delivery_icons[i].set_position(Vector2(89 + new_x, 69 + new_y))
			pass
		else:
			delivery_icons[i].set_position(Vector2(89 + del_x, 69 + del_y))
