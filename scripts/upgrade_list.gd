@tool class_name UpgradeList extends Object
## Utility class for holding all the upgrades, so they can be easily modified/balance from one place
## And so they don't take up space in other scripts

static var ENGINE_MAX_FORCE := UpgradeableStat.new(
	[2500.0, 4000.0, 6000.0],
	[15, 20],
	[&"Improved Fuel Mixture", &"Mana Potion Fuel Injection"],
	&"Increases engine force by XX%")
	
static var THROTTLE_SPEED := UpgradeableStat.new(
	[6000.0, 8000.0, 10000.0],
	[10, 15],
	[&"Engine Modification", &"Engine Enchantment"],
	&"Improves acceleration by XX%")
	
static var MAX_STEERING_ANGLE := UpgradeableStat.new(
	[TAU / 12.0, TAU / 9.0],
	[10],
	[&"Modified Steering"],
	&"Increases steering angle by XX%")

static var MAX_MANA := UpgradeableStat.new(
	[100, 150, 250, 500],
	[5, 10, 20],
	[&"Magic Training", &"Wizardry Practicum", &"Arcane Study"],
	&"Increases max mana by XX%")

static var PASSIVE_MANA_GAIN := UpgradeableStat.new(
	[100.0 / 60.0, 200.0 / 60.0, 500.0 / 60.0, 2500.0 / 60.0],
	[5, 10, 30],
	[&"Ancient Wizard Hat", &"Witchcraft", &"Forbidden Tomes"],
	&"Increase passive mana gain by XX%")

static var TEMPERATURE_CHANGE_FACTOR := UpgradeableStat.new(
	[1.0, 0.85, 0.66666666666667],
	[15, 20],
	[&"Insulated Pizza Boxes", &"Pizza Stasis"],
	&"Decreases the speed at which pizzas cool down by XX%")
