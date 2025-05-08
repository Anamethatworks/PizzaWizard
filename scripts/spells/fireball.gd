extends Spell
class_name FireballSpell

func _init(powr: float) -> void:
	var name = "Fireball"
	var cost = int(powr * 0.8)
	spell_scene = preload("res://scenes/packed scenes/spell_effects/fireball.tscn")
	super._init(cost, powr, name, "Creates a ball of fire that clears the road ahead.")

func cast(caster : Node3D) -> void:
	super.cast(caster)
	var fireball = spell_scene.instantiate()
	fireball.global_transform = caster.global_transform
	fireball.speed = 50/power
	fireball.size = power/25
	caster.get_tree().root.add_child(fireball)
