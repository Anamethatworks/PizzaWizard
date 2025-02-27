class_name Magic extends Node
## Class for magic and spells
## Spells are not implemented, but mana is (as of 2/27)

static var max_mana: float = 100.0 ## The max mana the player can hold at once
static var mana: float = 0.0 ## The current mana level the player has


## The player will passively gain mana at this rate (MP/sec)
## I don't know if this is how we want the player to gain mana, but it could be an upgrade at least
## It may be interesting to add other ways to gain mana (pickups, awarding mana for style)
static var mana_passive_gain: float = 100.0 / 60.0




func _physics_process(delta: float) -> void:
	mana = minf(max_mana, mana + mana_passive_gain * delta)
