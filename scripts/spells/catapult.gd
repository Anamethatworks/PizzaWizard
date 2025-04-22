extends Spell
class_name CatapultSpell

func _init(pow : float) -> void:
	var cost = pow * 0.2
	var name = "Catapult"
	super._init(cost, pow, name, "Flings the caster forward over obstacles.")

func is_valid_casting(caster : Node3D) -> bool:
	var mana_valid : bool = super.is_valid_casting(caster)
	var player : Player = caster.get_parent_node_3d()
	return mana_valid and player.is_any_tire_on_ground() # or player is stationary

func cast(caster : Node3D) -> void:
	super.cast(caster)
	var casterBody : RigidBody3D = caster.get_parent_node_3d()
	var force = casterBody.global_basis * Vector3(0, power * 250, -power * 1_000)
	var player : Player = caster.get_parent_node_3d()
	player.ignore_failsafe_timer = 1.0
	# TODO : Knock cars off road, add effect
	casterBody.apply_impulse(force)
