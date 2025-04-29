class_name Caster extends Node3D
## Handles casting & display of magic information

## Gives access to the caster to other parts of the code
static var active_caster : Caster

## The maximum amount of spells the player can hold at once
const MAX_SPELLS = 5

## The minimum time between spell castings
const MAX_COOLDOWN : float = 0.5

## The speed at which the mana bar will change
const BAR_CHANGE_SPEED = 5.0

## The amount of time in seconds that must pass to gain passive mana refuel
const PASSIVE_GAIN_COOLDOWN_MAX : float = 1

## An array of [Spell] objects, expands as the player collects spells
var spells : Array[Spell]

## The amount of time left before the player can cast another spell
var cooldown : float = 0

## Whether the player is in the learn spell UI
var learning_spell : Spell = null

## The index of the selected [Spell] in the [spells] array
var selected : int = 0

## The amount of time left before the passive mana regain tick
var passive_gain_cooldown : float = 0.0

## The mana bar UI  element
@export var mana_bar : ProgressBar
@export var mana_bar_text : RichTextLabel
@export var mana_bar_particles : GPUParticles2D

## The container of the current spell
@export var spell_display_panel : PanelContainer

# For the learn spell UI
@export var learn_spell_ui : GridContainer

@onready var ui_theme = preload("res://assets/UI themes/small_UI.tres")

## Adds a spell to the spell list
func learn_spell(new_spell : Spell) -> void:
	if len(spells) > MAX_SPELLS:
		## learning_spell = new_spell
		
		## # display currently equipped spells as buttons
		## learn_spell_ui.visible = true
		## for i in range(1, len(spells) + 1):
		##  	var spell_button : Button = Button.new()
		##  	spell_button.add_child(spells[i-1].get_spell_card())
		##  	learn_spell_ui.add_child(spell_button)
		##  	spell_button.button_down.connect(_select_spell.bind(i))
		
		spells.pop_front()
		spells.append(new_spell)
	else:
		spells.append(new_spell)
	change_displayed_spell_card(new_spell.get_spell_card())
		
func _select_spell(spell_index : int) -> void:
	assert(learning_spell != null)
	spells[spell_index] = learning_spell
	for child in learn_spell_ui.get_children():
		queue_free()
	learn_spell_ui.visible = false
	learning_spell = null
		
## Changes current displayed spell
func change_displayed_spell_card(new_spell_card : Control) -> void:
	new_spell_card.theme = ui_theme
	spell_display_panel.get_child(0).queue_free()
	spell_display_panel.add_child(new_spell_card)
	#print (spell_display_panel.name)

func _ready() -> void:
	Magic.mana = Magic.max_mana
	mana_bar.max_value = Magic.max_mana
	mana_bar.value = Magic.mana
	active_caster = self

	mana_bar_text.text = "Mana: " + str(floori(Magic.mana)) + "/" + str(floori(Magic.max_mana))
	mana_bar_particles.global_position = Vector2(14 + (205 * (Magic.mana / Magic.max_mana)), DisplayServer.window_get_size().y - 36)

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
		mana_bar_text.text = "Mana: " + str(floori(Magic.mana)) + "/" + str(floori(Magic.max_mana))
		mana_bar_particles.process_material.emission_box_extents = Vector3(205 * (Magic.mana / Magic.max_mana), 1.0, 1.0)
		mana_bar_particles.global_position = Vector2(14 + (205 * (Magic.mana / Magic.max_mana)), DisplayServer.window_get_size().y - 36)
		print (mana_bar_particles.global_position)
	
	# If the player has no spells, no more needs to be done
	if len(spells) <= 0:
		return
		
	# Cast spell if possible
	if cooldown > 0:
		cooldown -= delta
	if Input.is_action_just_pressed("CastSpell") and (learning_spell == null):
		if cooldown <= 0:
			spells[selected].attempt_to_cast(self)
			cooldown = MAX_COOLDOWN
	
	# Handle scrolling through the spell list
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
		
	# Handle number key selection
	for i in range(1, 6):
		if Input.is_action_just_pressed("Select%d" % i):
			if (learning_spell == null):
				if i >= len(spells):
					selected = len(spells) - 1
				else:
					selected = i
				change_displayed_spell_card(spells[selected].get_spell_card())
			else:
				_select_spell(i)
