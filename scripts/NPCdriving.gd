extends Node3D

var moveSpeed = 10
var Blocked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Blocked == false:
		get_parent().progress += moveSpeed * delta


func _on_rigid_body_3d_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Blocked = true
	print(Blocked)


func _on_rigid_body_3d_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		Blocked = false
	print(Blocked)
