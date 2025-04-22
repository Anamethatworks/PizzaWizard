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

# A brief description of what the spell does
var spell_desc : String

# The associated scene the spell might instantiate under certain circumstances
var spell_scene : PackedScene

# Init function
func _init(cost : float, pow : float, name : String = "Default Spell", desc : String = "Does nothing."):
	mana_cost = cost
	power = pow
	spell_name = name
	spell_desc = desc
	if power > MAJOR_THRESHOLD:
		spell_name = "Major " + spell_name
		mana_cost *= 1.5
	elif power <= MINOR_THRESHOLD:
		spell_name = "Minor " + spell_name
		mana_cost *= 0.5

# Overloadable function, checks if a casting is valid
func is_valid_casting(caster : Node3D) -> bool:
	return Magic.mana >= mana_cost

# Attempts to cast a spell, fails if there's not enough mana, takes position of caster
func attempt_to_cast(caster : Node3D) -> void:
	if is_valid_casting(caster):
		Magic.add_mana(-mana_cost)
		cast(caster)
	else:
		fail(caster)

# Overloadable function, called when spell is cast, takes position of caster
func cast(caster : Node3D) -> void:
	print("Casted %s for %d mana!" % [spell_name, mana_cost])

# Called when spell fails to cast, takes position of caster
func fail(caster : Node3D) -> void:
	# TODO: Add a poof of particles around the player to
	# indicate the spell failed
	print("Cast of %s failed!" % spell_name)

# Returns the info of the spell formatted into a UI element
func get_spell_card() -> Control:
	var card : Label = Label.new()
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var info_text = "%s\nPower: %d\nCost: %d mana\n" % [spell_name, power, mana_cost]
	var desc_formatted = ""
	var chars_since_newline : int = 0
	for i in len(spell_desc):
		desc_formatted += spell_desc[i]
		chars_since_newline += 1
		if chars_since_newline >= 40:
			var j : int = len(desc_formatted) - 1
			while (desc_formatted[j] != " ") and (j >= 0):
				j -= 1
			if j != 0:
				desc_formatted = desc_formatted.insert(j + 1, "\n")
				chars_since_newline = 0
	card.text = info_text + spell_desc
	return card
