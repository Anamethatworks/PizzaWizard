extends Spell
class_name CatapultSpell

func _init(pow : float) -> void:
	var cost = pow * 0.2
	var name = "Catapult"
	super._init(cost, pow, name)

func is_valid_casting(caster : Node3D) -> bool:
	var mana_valid : bool = super.is_valid_casting(caster)
	var playerRoot : Node3D = caster.get_parent_node_3d()
	return mana_valid

func cast(caster : Node3D) -> void:
	super.cast(caster)
	var casterBody : RigidBody3D = caster.get_parent_node_3d()
	var force = casterBody.global_basis * Vector3(0, power * 250, -power * 1_000)
	# TODO : 
	casterBody.apply_impulse(force)
