extends Area3D
class_name DropoffPoint
## A location that can order pizzas

@export var  GLOWY_MATERIAL: Material

@onready var building: MeshInstance3D = get_parent_node_3d().get_child(0)

## The current [Order] this location has, or [code]null[/code] if there is none
var current_order: Order = null

## A timer for the cooldown between orders
var order_cooldown: float = 0.0

 ## If set to [code]true[/code], this location will not have a cooldown between placing orders.
@export var ignore_cooldown: bool = false

## The minimum time (sec) in-between two orders being placed from the same location
const ORDER_COOLDOWN_DURATION: float = 30.0

## The amount the distance between the pizzeria and the destination effects par time
const PAR_DISTANCE_MULTIPLIER: float = 0.5

## A timer for how long the order has been waiting
var time_since_order: float = 0.0

func _ready() -> void:
	DeliveryManager.addDropoffPoint(self)
	monitoring = false
	init_particles()

## Calculates par time for travel between two points
static func calculate_par_time(hither : Vector3, yon : Vector3) -> float:
	var distance = manhattan_distance(hither, yon)
	return distance * PAR_DISTANCE_MULTIPLIER

static func manhattan_distance(v1: Vector3, v2: Vector3) -> float:
	return absf(v1.x - v2.x) + absf(v1.y - v2.y) + absf(v1.z - v2.z)




## Adds a new order at this location (if possible). Returns [code]current_order[/code] if successful, [code]null[/code] otherwise
func add_order() -> Order:
	if is_instance_valid(current_order) or order_cooldown > 0.0:
		# There is already an order here or this location is still on cooldown
		return null
	var par_time: float = calculate_par_time(global_position, Pizzeria.active_location.global_position)
	current_order = Order.new(self, par_time)
	start_dropoff_effects()
	monitoring = true
	return current_order

func _process(delta: float) -> void:
	if current_order != null:
		time_since_order += delta
	if order_cooldown > 0.0:
		order_cooldown -= delta

## Fulfills the order and gives the player their points + money
func deliver_pizza() -> void:
	var pizza_temp := current_order.ordered_pizza.temperature
	current_order.fulfill(pizza_temp, time_since_order)
	time_since_order = 0
	current_order = null
	if not ignore_cooldown:
		order_cooldown = ORDER_COOLDOWN_DURATION
	set_deferred("monitoring", false)

func _on_body_entered(body: Node3D) -> void:
	# Determine if the body is the player
	if body.name == "Player":
		deliver_pizza()
		var minimap_node = $"../../../MiniMap"
		var ui_manager = $"../../../UIPanel/UIManager"
		minimap_node.call("remove_delivery_icon", (global_position))
		FullScreenMap.singleton.call("remove_order_location", Vector2(global_position.x, global_position.z))
		ui_manager.call("remove_order_ticket", (global_position))
		end_dropoff_effects()

## Initializes particles to be the same size and position as the collision for the dropoff point
## Only needs to be run once at startup
func init_particles() -> void:
	var particles: GPUParticles3D = $GPUParticles3D
	for child: Node in get_children():
		if child is CollisionShape3D:
			particles.scale = child.shape.size / 2.0
			particles.position = child.position


## Starts dropoff effects (building glow, particles)
## Needs to be run each time the effects should start
func start_dropoff_effects() -> void:
	$GPUParticles3D.emitting = true
	building.material_override = GLOWY_MATERIAL

## Stops the dropoff effects and returns the building to its normal appearance
func end_dropoff_effects() -> void:
	building.material_override = null
	$GPUParticles3D.emitting = false
