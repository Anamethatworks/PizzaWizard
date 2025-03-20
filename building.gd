class_name Building extends MeshInstance3D

@export var CUTOUT_MATERIAL: Material

@onready var building_mesh: MeshInstance3D = get_parent().get_child(0)

func _ready() -> void:
	# Create a duplicate of the mesh to cast shadows
	var shadow_caster: MeshInstance3D = building_mesh.duplicate()
	shadow_caster.name = &"Shadows"
	get_parent().add_child.call_deferred(shadow_caster)
	shadow_caster.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

func start_cutout() -> void:
	if !is_instance_valid(building_mesh.material_override):
		building_mesh.material_override = CUTOUT_MATERIAL
		self.visible = true

func end_cutout() -> void:
	building_mesh.material_override = null
	self.visible = false
