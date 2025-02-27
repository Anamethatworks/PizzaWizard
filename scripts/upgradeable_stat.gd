@tool
class_name UpgradeableStat extends Node
## Class for a stat that can be modified by upgrades

static var upgrade_list: Array[UpgradeableStat] = [] ## A static list of every upgradeable stat

var upgrade_tiers: int ## How many tiers are possible (if 1, there are two tiers, the default (0) and one upgrade (1))
var values: Array[Variant] ## What the value is at each level (with values[0] being the default)
var costs: Array[int] ## The cost for each upgrade. It's length should be one shorter than values, because values[0] is the default and has no cost
var current_tier: int = 0

var value: Variant:
	get:
		return values[current_tier]

## How to initialize an UpgradeableStat:
## tier_values is an array containing the value of the stat at each upgrade tier. tier_values[0] is the default
## tier_costs is how much money it costs to buy each tier. tier_costs[0] is the price for the first upgrade (tier_values[1]),
## so tier_costs should be one shorter than tier_values
func _init(tier_values: Array[Variant], tier_costs: Array[int]) -> void:
	assert(len(tier_values) == len(tier_costs) + 1, "Mismatch between tier values and costs. Should have one more value than costs (the default value)")
	upgrade_tiers = len(tier_costs)
	values = tier_values
	costs = tier_costs
	upgrade_list.append(self)

## Returns true if this stat is at its maximum upgrade, and false otherwise
func is_at_max_tier() -> bool:
	assert(current_tier <= upgrade_tiers, "WARNING: SOMEHOW SURPASSED MAXIMUM LEVEL")
	return current_tier == upgrade_tiers

## Returns true if there is an available upgrade that the player can afford for this stat
func can_afford_upgrade() -> bool:
	if is_at_max_tier():
		return false
	return Money.player_gold >= costs[current_tier]

func buy_upgrade() -> void:
	if not can_afford_upgrade():
		return
	Money.player_gold -= costs[current_tier]
	current_tier += 1
