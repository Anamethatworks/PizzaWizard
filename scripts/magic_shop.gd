class_name MagicShop extends Area3D
## Class that handles the magic shop mechanics

## The current spell being offered by the shop
var held_spell : Spell

## The cost of the current spell being offered
var money_cost : int

## The number of spells purchased from this shop
var purchased_spells : int = 0

## How fast the number of purchased spells will cause
## the cost of spells from this shop to increase
const SPELL_COST_VARIANCE_SLOPE : float = 0.6

## How fast the number of purchased spells will cause
## the rarity of spells from this shop to increase.
const SPELL_RARITY_VARIANCE_SLOPE : float = 10

## Contains the shop UI
@export var shop_ui : Panel

## Whether or not the player is present in the ShopArea
var player_here : bool

## Enum that contains the spell types available for
## generation.
enum SPELL_TYPE {
	CATAPULT,
	FIREBALL,
	INCINERATE,
	REFRIGERATE
}

## Function that attaches the current spell and cost
## to the UI.
func display_wares() -> void:
	var vbox : VBoxContainer = shop_ui.get_child(0)
	
	# Clear current children if there are any
	var child_range : Array = range(len(vbox.get_children()))
	child_range.reverse()
	for i in child_range:
		var child : Node = vbox.get_child(i)
		vbox.remove_child(child)
		child.queue_free()
		
	# Attach price and spellcard to shop UI
	var spellcard : Control = held_spell.get_spell_card()
	var price : Label = Label.new()
	price.text = "Price: %.2f" % money_cost
	vbox.add_child(spellcard)
	vbox.add_child(price)

## Function that creates a random new spell and cost
## for the spell shop
func new_spell() -> void:
	# Pick a random spell type and spell power
	var spell_type : SPELL_TYPE = randi() % SPELL_TYPE.size()
	var generated_spell : Spell
	var spell_power : float = clampf(
		30 + SPELL_RARITY_VARIANCE_SLOPE * (purchased_spells + 1) * (2 * randf() - 1),
		10, 100
	)
	
	# Create spell object
	match spell_type:
		SPELL_TYPE.CATAPULT:
			generated_spell = CatapultSpell.new(spell_power)
		SPELL_TYPE.FIREBALL:
			generated_spell = FireballSpell.new(spell_power)
		SPELL_TYPE.INCINERATE:
			generated_spell = ChangeTempSpell.new(spell_power, true)
		SPELL_TYPE.REFRIGERATE:
			generated_spell = ChangeTempSpell.new(spell_power, false)
		_:
			assert(false)
			
	# Assign generated spell and generate a cost
	held_spell = generated_spell
	money_cost = clamp(
		int(5 + SPELL_COST_VARIANCE_SLOPE * (purchased_spells + 1) * (2 * randf() - 1)),
		1, 50
	)
	
	# Update shop UI
	display_wares()

## Function that overwrites [held_spell] with a new spell
## and gives the spell to the player. Returns true if
## spell was purchased, false if it wasn't.
func purchase_spell() -> bool:
	if Money.player_gold >= money_cost:
		Money.player_gold -= money_cost
		Caster.active_caster.learn_spell(held_spell)
		purchased_spells += 1
		new_spell()
		return true
	else:
		return false
	
func _ready() -> void:
	new_spell()
	
func _process(_delta: float) -> void:
	# update UI
	shop_ui.set_position(
		get_viewport().get_camera_3d().unproject_position(
			get_parent_node_3d().global_position
		) - shop_ui.size * 0.5
	)
	
	# handle purchasing
	if player_here and Input.is_action_just_pressed("Honk"):
		if not purchase_spell():
			pass # TODO : Add indication the transaction didn't go through

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_here = true

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_here = false
