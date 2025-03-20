extends RigidBody3D

# The speed at which the fireball moves
@export var speed : float

# The size of the fireball
@export var size : float

# The collider of the fireball
@export var collider : CollisionShape3D

# The mesh of the fireball
@export var mesh : Node3D

# For scaling the fireball to its full size
var scale_up : float = 0

# The maximum lifetime of the fireball
const MAX_LIFETIME : float = 30.0

# The elapsed lifetime of the fireball
var elapsed_lifetime : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_constant_force(transform.basis * Vector3(0, 0, -speed))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if scale_up < 1:
		scale_up += delta
		if scale_up > 1:
			scale_up = 1
		change_size(lerp(Vector3(size, size, size), mesh.scale, 1 - scale_up))
	elapsed_lifetime += delta
	if elapsed_lifetime >= MAX_LIFETIME:
		dissipate()
		
func change_size(new_size : Vector3) -> void:
	mesh.scale = new_size
	collider.shape.radius = new_size.x/2

# Called when the fireball is destroyed
func dissipate():
	for child in get_children():
		child.queue_free()
	queue_free()

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	# TODO: Knock cars off the road
	dissipate()
