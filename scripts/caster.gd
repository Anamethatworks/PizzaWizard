class_name Caster extends Node3D
## Handles casting & display of magic information

## The maximum amount of spells the player can hold at once
const MAX_SPELLS = 5

## The speed at which the mana bar will change
const BAR_CHANGE_SPEED = 5.0

## An array of [Spell] objects, expands as the player collects spells
static var spells : Array[Spell]

## The index of the selected [Spell] in the [spells] array
var selected : int = 0

## The minimum time between spell castings
const MAX_COOLDOWN : float = 0.5

## The amount of time left before the player can cast another spell
static var cooldown : float = 0

## The amount of time in seconds that must pass to gain passive mana refuel
const PASSIVE_GAIN_COOLDOWN_MAX : float = 1

## The amount of time left before the passive mana regain tick
var passive_gain_cooldown : float = 0.0

## The mana bar UI  element
@export var mana_bar : ProgressBar

## The container of the current spell
@export var spell_display_panel : PanelContainer

## Adds a spell to the spell list
static func learn_spell(new_spell : Spell) -> void:
	spells.append(new_spell)
	if len(spells) > MAX_SPELLS:
		# TODO: UI system to prompt player to select a spell to
		# discard. For now, pop our oldest spell.
		spells.pop_at(0)
		
## Changes current displayed spell
func change_displayed_spell_card(new_spell_card : Control) -> void:
	spell_display_panel.get_child(0).queue_free()
	spell_display_panel.add_child(new_spell_card)

func _ready() -> void:
	Magic.mana = Magic.max_mana
	mana_bar.max_value = Magic.max_mana
	mana_bar.value = Magic.mana
	
	# Debug stuff
	learn_spell(CatapultSpell.new(50))
	spells.append(FireballSpell.new(50))
	change_displayed_spell_card(spells[selected].get_spell_card())

# TODO: Add indicators to mold earth, warp spells to indicate where
# the ramp will appear and the player will be teleported respectively
func _process(delta : float) -> void:
	# Passively gain mana
	passive_gain_cooldown -= delta
	if (passive_gain_cooldown <= 0):
		passive_gain_cooldown = PASSIVE_GAIN_COOLDOWN_MAX
		Magic.add_mana(Magic.mana_passive_gain)
	
	# If the mana max value changes, change bar maximum
	# while maintaining the percentage of mana in the bar
	if Magic.max_mana != mana_bar.max_value:
		var ratio : float = Magic.max_mana / mana_bar.max_value
		mana_bar.max_value = Magic.max_mana
		Magic.change_mana(int(Magic.mana * ratio))
		
	# Lerp the mana bar value to the current mana value
	if mana_bar.value != Magic.mana:
		mana_bar.value = lerpf(mana_bar.value, Magic.mana, delta * BAR_CHANGE_SPEED)
		if abs(mana_bar.value - Magic.mana) <= mana_bar.step:
			mana_bar.value = Magic.mana
	
	# If the player has no spells, no more needs to be done
	if len(spells) <= 0:
		return
		
	# Cast spell if possible
	if cooldown > 0:
		cooldown -= delta
	if Input.is_action_just_pressed("CastSpell"):
		if cooldown <= 0:
			spells[selected].attempt_to_cast(self)
			cooldown = MAX_COOLDOWN
	
	# Scroll through the spell list
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
		change_displayed_spell_card(spells[selected].get_spell_card())
