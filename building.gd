class_name Building extends MeshInstance3D

@export var CUTOUT_MATERIAL: Material

func start_cutout() -> void:
	if !is_instance_valid(get_parent().get_child(0).material_override):
		get_parent().get_child(0).material_override = CUTOUT_MATERIAL
		self.visible = true

func end_cutout() -> void:
	get_parent().get_child(0).material_override = null
	self.visible = false
