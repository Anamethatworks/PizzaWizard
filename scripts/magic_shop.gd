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

## Enum that contains the spell types available for
## generation.
enum SPELL_TYPE {
	CATAPULT,
	FIREBALL,
	INCINERATE,
	REFRIGERATE
}

## Function that creates a random new spell and cost
## for the spell shop
func new_spell() -> void:
	var spell_type : SPELL_TYPE = randi() % SPELL_TYPE.size()
	var generated_spell : Spell
	var spell_power : float = 30 + SPELL_RARITY_VARIANCE_SLOPE * (purchased_spells + 1) * (2 * randf() - 1)
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
	held_spell = generated_spell
	money_cost = int(5 + SPELL_COST_VARIANCE_SLOPE * (purchased_spells + 1) * (2 * randf() - 1))

## Function that overwrites [held_spell] with a new spell
## and gives the spell to the player. Returns true if
## spell was purchased, false if it wasn't.
func purchase_spell() -> bool:
	if Money.player_gold >= money_cost:
		Money.player_gold -= money_cost
		Caster.learn_spell(held_spell)
		purchased_spells += 1
		new_spell()
		return true
	else:
		return false
	
func _ready() -> void:
	new_spell()

func _on_area_entered(area: Area3D) -> void:
	pass
