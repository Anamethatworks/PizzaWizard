class_name FullScreenMap extends CenterContainer

@onready var player: VehicleBody3D = $"../Player"
@onready var pizzeria: Node3D = $"../Pizzeria"

const packed_order_icon: PackedScene = preload("res://scenes/UI/full_screen_map_order_icon.tscn")
var orders: Dictionary[Vector2, Control] = {}

static var singleton: CenterContainer

func _ready() -> void:
	singleton = self
	
	set_visible(false) # I know I could do this in the editor, but I want to be able to edit it ...
	# ... without constantly toggling its visibility
		
	# Pizzeria icon
	var pizzeria_uv = get_uv_from_xz(Vector2(pizzeria.global_position.x, pizzeria.global_position.z))
	$Icons/Pizzeria.position.x = pizzeria_uv.x * $Icons.size.x
	$Icons/Pizzeria.position.y = pizzeria_uv.y * $Icons.size.y

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Map"):
		set_visible(true)
	elif Input.is_action_just_released("Map"):
		set_visible(false)
		
#region icons
	if visible:
		# Player
		var player_uv: Vector2 = get_uv_from_xz(Vector2(player.global_position.x, player.global_position.z))
		$Icons/Player.position.x = player_uv.x * $Icons.size.x
		$Icons/Player.position.y = player_uv.y * $Icons.size.y
		$Icons/Player.rotation = -player.rotation.y
		
#endregion
		

## Returns a position on the map in screen space given a position in the world
func get_uv_from_xz(xz: Vector2) -> Vector2:
	var u: float = (-xz.x + 206.25) / 412.5
	var v: float = (-xz.y + 163.207) / 275
	return Vector2(u, v)

## Adds an icon for an order at a certain location
func add_order_location(to_add: Vector2) -> void:
	if orders.has(to_add):
		push_warning("Tried to add an order icon that already exists.")
		return
	var control: Control = packed_order_icon.instantiate()
	$Icons.add_child(control)
	orders.set(to_add, control)
	var order_uv = get_uv_from_xz(Vector2(to_add.x, to_add.y))
	control.position.x = order_uv.x * $Icons.size.x
	control.position.y = order_uv.y * $Icons.size.y

## Removes an icon for an order at a certain location
func remove_order_location(target: Vector2) -> void:
	if not orders.has(target):
		push_warning("Tried to remove an order icon that does not exist.")
		return
	orders[target].queue_free()
	orders.erase(target)
