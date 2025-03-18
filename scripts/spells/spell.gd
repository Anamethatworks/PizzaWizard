extends Object
class_name Spell

# The threshold past which a spell is considered Major
const MAJOR_THRESHOLD = 50

# The threshold before which a spell is considered Minor
const MINOR_THRESHOLD = 10

# The cost of the spell in mana
var mana_cost : float

# The power of the spell, use depends on spell
var power : float

# The spell name
var spell_name : String

# The associated scene the spell might instantiate under certain circumstances
var spell_scene : PackedScene

# Init function
func _init(cost : float, pow : float, name : String = "Default Spell"):
	mana_cost = mana_cost
	power = pow
	spell_name = name
	if power > MAJOR_THRESHOLD:
		spell_name = "Major " + spell_name
		mana_cost *= 1.5
	elif power <= MINOR_THRESHOLD:
		spell_name = "Minor " + spell_name
		mana_cost *= 0.5

# Overloadable function, checks if a casting is valid
func is_valid_casting(cast_pos : Vector3) -> bool:
	return Magic.mana >= mana_cost

# Attempts to cast a spell, fails if there's not enough mana, takes position of caster
func attempt_to_cast(cast_pos : Vector3) -> void:
	if is_valid_casting(cast_pos):
		Magic.mana -= mana_cost
		cast(cast_pos)
	else:
		fail(cast_pos)

# Overloadable function, called when spell is cast, takes position of caster
func cast(cast_pos : Vector3) -> void:
	print("Casted %s!" % spell_name)

# Called when spell fails to cast, takes position of caster
func fail(cast_pos : Vector3) -> void:
	# TODO: Add a poof of particles around the player to
	# indicate the spell failed
	print("Cast of %s failed!" % spell_name)
