@tool
class_name UpgradeList extends Object
## Utility class for holding all the upgrades, so they can be easily modified/balance from one place
## And so they don't take up space in other scripts

static var ENGINE_MAX_FORCE := UpgradeableStat.new(
	[2500.0, 4000.0, 6000.0],
	[15, 20],
	["Improved Fuel Mixture", "Mana Potion Fuel Injection"],
	"Increases Top Speed")
	
static var THROTTLE_SPEED := UpgradeableStat.new(
	[6000.0, 8000.0, 10000.0],
	[10, 15],
	["Upgraded Engine", "Enchanted Engine"],
	"Improves Acceleration")
	
static var MAX_STEERING_ANGLE := UpgradeableStat.new(
	[TAU / 12.0, TAU / 9.0],
	[10],
	["Modified Steering"],
	"Increases Steering Angle")

static var MAX_MANA := UpgradeableStat.new(
	[100, 150, 250, 500],
	[5, 10, 20],
	["Magic Training", "Wizardry Practicum", "Arcane Study"],
	"Increases Max Mana")

static var PASSIVE_MANA_GAIN := UpgradeableStat.new(
	[100.0 / 60.0, 200.0 / 60.0, 500.0 / 60.0, 2500.0 / 60.0],
	[5, 10, 30],
	["Ancient Wizard Hat", "Witchcraft", "Forbidden Tomes"],
	"Increase Passive Mana Gain")
