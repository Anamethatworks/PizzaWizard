extends Control
class_name MinimapManager

@onready var pizzeria_pos = $"MinMapIconMask/PizzeriaPos"
@onready var minimap_pos = $"MinMapRoundMask/MinMapRound"
@onready var player_icon = $"MinMapIconMask/PlayerPos"
@onready var player = $"../Player"
static var delivery_icon_scene = preload("res://scenes/deliver_pos.tscn")

var pizzeria_location = Vector3(10.3, 0, -4)

var minimap_offset = Vector2(-286, -388)
var pizzeria_offset = Vector2(64, 91)
var map_to_world_ratio = 1.64

static var deliver_locations : Array[Vector3] = []
static var delivery_icons : Array[Control] = []

static func add_delivery_icon(loc: Vector3) -> void:
	deliver_locations.append(loc)
	var new_icon = delivery_icon_scene.instantiate()
	delivery_icons.append(new_icon)

static func remove_delivery_icon(loc: Vector3) -> void:
	for i in range(len(deliver_locations)):
		if deliver_locations[i] == loc:
			deliver_locations.remove_at(i)
			delivery_icons.remove_at(i)

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
	pizzeria_pos.set_position(Vector2(pizzeria_offset.x + map_x, pizzeria_offset.y + map_y))
	
	#rotates player icon on minimap
	player_icon.rotation = -player.rotation.y
