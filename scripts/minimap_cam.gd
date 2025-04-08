extends Camera3D

@onready var player: VehicleBody3D = $"../../../../../Player"

func _process(delta: float) -> void:
	self.global_position.x = player.global_position.x
	self.global_position.z = player.global_position.z
