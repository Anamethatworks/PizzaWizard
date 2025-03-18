extends Object
class_name Spell

# Overloadable value, the spell name, for debug purposes
const spell_name = "DEFAULT_SPELL"

# The cost of the spell in mana
var mana_cost : float = 0

# The associated scene the spell might instantiate under certain circumstances
var spell_scene : PackedScene

# Attempts to cast a spell, fails if there's not enough mana, takes position of caster
func attempt_to_cast(cast_pos : Vector3) -> void:
	if Magic.mana < mana_cost:
		fail(cast_pos)
	else:
		Magic.mana -= mana_cost
		cast(cast_pos)

# Overloadable function, called when spell is cast, takes position of caster
func cast(cast_pos : Vector3) -> void:
	print("Casted %s!" % spell_name)

# Called when spell fails to cast, takes position of caster
func fail(cast_pos : Vector3) -> void:
	# TODO: Add a poof of particles around the player to
	# indicate the spell failed
	print("Cast failed!")
