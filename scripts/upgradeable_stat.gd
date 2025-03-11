@tool class_name UpgradeableStat extends Node
## Class for a stat that can be modified by upgrades

static var upgrade_list: Array[UpgradeableStat] = [] ## A static list of every upgradeable stat

var upgrade_tiers: int ## How many tiers are possible (if 1, there are two tiers, the default (0) and one upgrade (1))
var values: Array[Variant] ## What the value is at each level (with values[0] being the default)
var costs: Array[int] ## The cost for each upgrade. It's length should be one shorter than values, because values[0] is the default and has no cost
var current_tier: int = 0
var upgrade_names: Array[StringName] ## The name of each upgrads. Like the cost, should have one fewer entry than there are values


## Description of the upgrade. May contain "XX%", in which case
## get_description() should be used to automatically calculate percentage increase
var description: StringName = &"" 


## THIS IS THE ACTUAL STAT MODIFIED BY THE UPGRADES
var value: Variant:
	get: return values[current_tier]

## How to initialize an UpgradeableStat:
## tier_values is an array containing the value of the stat at each upgrade tier. tier_values[0] is the default
## tier_costs is how much money it costs to buy each tier. tier_costs[0] is the price for the first upgrade (tier_values[1]),
## so tier_costs should be one shorter than tier_values
## names is the name for each upgrade tier (should have the same length as tier_costs)
## desc is the description of the upgrade
func _init(tier_values: Array[Variant], tier_costs: Array[int], names: Array[StringName], desc: StringName) -> void:
	assert(len(tier_values) == len(tier_costs) + 1, "Mismatch between tier values and costs. Should have one more value than costs (the default value)")
	assert(len(tier_costs) == len(names), "Mismatch between costs and names. Should have an equal length.")
	upgrade_tiers = len(tier_costs)
	values = tier_values
	costs = tier_costs
	upgrade_names = names
	description = desc
	upgrade_list.append(self)
	UpgradeStation.unpaired_upgrades.append(self)
	UpgradeStation.unpaired_upgrades.shuffle()

## Returns true if this stat is at its maximum upgrade, and false otherwise
func is_at_max_tier() -> bool:
	assert(current_tier <= upgrade_tiers, "WARNING: SOMEHOW SURPASSED MAXIMUM LEVEL")
	return current_tier == upgrade_tiers

## Returns true if there is an available upgrade that the player can afford for this stat
func can_afford_upgrade() -> bool:
	if is_at_max_tier(): return false
	return Money.player_gold >= costs[current_tier]

## Consumes some of the player's gold and upgrades the stat once, if possible
func buy_upgrade() -> void:
	if not can_afford_upgrade(): return
	Money.player_gold -= costs[current_tier]
	current_tier += 1

## Gets the name of the next level upgrade
func get_upgrade_name() -> StringName:
	if is_at_max_tier(): return &"Max Level"
	return upgrade_names[current_tier]

## Gets the description of the upgrade, with the correct percentage (if possible)
func get_description() -> StringName:
	if len(values) > 1:
		if values[0] is int or values[0] is float:
			var increase: float = values[current_tier + 1] / values[current_tier]
			increase = absf(increase - 1.0)
			var percent_increase: int = roundi(increase * 100.0)
			return description.replace("XX%", str(percent_increase) + "%")
	return description
	

## Gets the cost of the next upgrade
func get_cost() -> int:
	if is_at_max_tier(): return 0
	return costs[current_tier]
