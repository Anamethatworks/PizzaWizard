class_name Magic
## Class for magic and spells
## Spells are not implemented, but mana is (as of 2/27)

static var max_mana: float: ## The max mana the player can hold at once
	get: return UpgradeList.MAX_MANA.value
static var mana: float = 0.0 ## The current mana level the player has


## The player will passively gain mana at this rate (MP/sec)
## I don't know if this is how we want the player to gain mana, but it could be an upgrade at least
## It may be interesting to add other ways to gain mana (pickups, awarding mana for style)
static var mana_passive_gain: float:
	get: return UpgradeList.PASSIVE_MANA_GAIN.value

## Adds delta_mana to the current mana
static func add_mana(delta_mana : float) -> void:
	mana = clampf(mana + delta_mana, 0, max_mana)

## Changes the current mana to new_mana
static func change_mana(new_mana : float) -> void:
	mana = clampf(new_mana, 0, max_mana)
