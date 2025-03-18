extends Node

# An array of [Spell] objects, expands as the player collects spells
var spells : Array[Spell]

# The index of the selected [Spell] in the [spells] array
var selected : int = 0

# The minimum time between spell castings
const MAX_COOLDOWN : float = 0.5

# The amount of time left before the player can cast another spell
var cooldown : float = 0

func _ready() -> void:
	spells.append(Spell.new())

func _process(delta : float) -> void:
	if len(spells) <= 0:
		return
		
	if cooldown > 0:
		cooldown -= delta
	
	if Input.is_action_just_pressed("CastSpell"):
		if cooldown <= 0:
			spells[selected].attempt_to_cast(self.get_parent().global_position)
			cooldown = MAX_COOLDOWN
		
	if Input.is_action_just_pressed("ScrollSpellNext"):
		if selected < len(spells) - 1:
			selected += 1
		else:
			selected = 0
	elif Input.is_action_just_pressed("ScrollSpellPrev"):
		if selected > 0:
			selected -= 1
		else:
			selected = len(spells) - 1

# Adds a spell to the spell list
func gain_spell(new_spell : Spell) -> void:
	spells.append(new_spell)
