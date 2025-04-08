class_name Magic extends Node
## Class for magic and spells

static var max_mana: float: ## The max mana the player can hold at once
	get: return UpgradeList.MAX_MANA.value
static var mana: float = 0.0 ## The current mana level the player has


## The player will passively gain mana at this rate (MP/sec)
## I don't know if this is how we want the player to gain mana, but it could be an upgrade at least
## It may be interesting to add other ways to gain mana (pickups, awarding mana for style)
static var mana_passive_gain: float:
	get: return UpgradeList.PASSIVE_MANA_GAIN.value




func _physics_process(delta: float) -> void:
	# Increment mana
	if !TimeManager.out_of_time:
		mana = minf(max_mana, mana + mana_passive_gain * delta)
