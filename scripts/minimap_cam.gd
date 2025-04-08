extends Camera3D

func _process(delta: float) -> void:
	self.global_position.x = $"../../..".global_position.x
	self.global_position.z = $"../../..".global_position.z
