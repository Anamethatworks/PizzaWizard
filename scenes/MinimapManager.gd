extends Control

@onready var pizzeria_pos = $"MinMapIconMask/PizzeriaPos"
@onready var minimap_pos = $"MinMapRoundMask/MinMapRound"
@onready var player = $"../Player"
var pizzeria_location = Vector3(10.3, 0, -4)

var minimap_offset = Vector2(-286, -388)
var pizzeria_offset = Vector2(64, 91)
var map_to_world_ratio = 1.64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var map_x = player.position.x * map_to_world_ratio
	var map_y = player.position.z * map_to_world_ratio
	minimap_pos.set_position(Vector2(minimap_offset.x + map_x, minimap_offset.y + map_y))
	
	var piz_x = pizzeria_location.x * map_to_world_ratio
	var piz_y = pizzeria_location.z * map_to_world_ratio
	pizzeria_pos.set_position(Vector2(pizzeria_offset.x + map_x, pizzeria_offset.y + map_y))
