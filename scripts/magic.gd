class_name Magic
## Class for magic and spells

static var max_mana: int: ## The max mana the player can hold at once
	get: return UpgradeList.MAX_MANA.value
static var mana: int = 0 ## The current mana level the player has


## The player will passively gain mana at this rate (MP/sec)
## I don't know if this is how we want the player to gain mana, but it could be an upgrade at least
## It may be interesting to add other ways to gain mana (pickups, awarding mana for style)
static var mana_passive_gain: int:
	get: return UpgradeList.PASSIVE_MANA_GAIN.value

## Adds delta_mana to the current mana
static func add_mana(delta_mana : int) -> void:
	mana = clamp(mana + delta_mana, 0, max_mana)

## Changes the current mana to new_mana
static func change_mana(new_mana : int) -> void:
	mana = clamp(new_mana, 0, max_mana)
