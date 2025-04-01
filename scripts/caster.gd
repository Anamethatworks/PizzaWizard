extends Node3D

# The maximum amount of spells the player can hold at once
const MAX_SPELLS = 5

# An array of [Spell] objects, expands as the player collects spells
var spells : Array[Spell]

# The index of the selected [Spell] in the [spells] array
var selected : int = 0

# The minimum time between spell castings
const MAX_COOLDOWN : float = 0.5

# The amount of time left before the player can cast another spell
var cooldown : float = 0

# Adds a spell to the spell list
func learn_spell(new_spell : Spell) -> void:
	spells.append(new_spell)
	if len(spells) > MAX_SPELLS:
		# TODO: UI system to prompt player to select a spell to
		# discard. For now, pop our oldest spell.
		spells.pop_at(0)

# Debug stuff
func _ready() -> void:
	Magic.mana = 10000000
	spells.append(CatapultSpell.new(50))

# TODO: Add indicators to mold earth, warp spells to indicate where
# the ramp will appear and the player will be teleported respectively
func _process(delta : float) -> void:
	if len(spells) <= 0:
		return
		
	if cooldown > 0:
		cooldown -= delta
	if Input.is_action_just_pressed("CastSpell"):
		if cooldown <= 0:
			spells[selected].attempt_to_cast(self)
			cooldown = MAX_COOLDOWN
	
	var scroll_next : bool = Input.is_action_just_pressed("ScrollSpellNext")
	var scroll_prev : bool = Input.is_action_just_pressed("ScrollSpellPrev")
	if scroll_next:
		selected += 1
	elif scroll_prev:
		selected -= 1	
	if scroll_next or scroll_prev:
		if selected >= len(spells):
			selected = 0
		elif selected < 0:
			selected = len(spells) - 1
		print("Switched to %s!" % spells[selected].spell_name)
