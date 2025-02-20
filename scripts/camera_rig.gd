extends Node3D

var pitch:float = 0.0
var yaw:float = 0.0
var CameraRotation = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		yaw -= event.relative.x * 0.05
		CameraRotation = yaw
		rotation_degrees = Vector3(0, yaw, 0)
		pitch -= event.relative.y * 0.08
		if pitch > -90:			pitch = -90
		if pitch < -60:			pitch = -60
		$Camera3D.rotation_degrees = Vector3(pitch, 0, 0)
