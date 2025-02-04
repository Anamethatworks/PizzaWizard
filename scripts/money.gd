extends Object
class_name Money
## Class for money and calculating payout (should be globally loaded)

## How tolerant the payment function is of temperature difference
const TEMPERATURE_TOLERANCE: float = 15.0
## The default amount the customer will tip
const BASE_TIP: float = 0.1

## The money the player has
static var player_gold: int = 0

## If this script is autoloaded, this function can be called from anywhere using [method Money.get_payout()]
## [param temp]: the temperature of the pizza
## [param goal_temp]: the temperature the customer wants it
## [param time]: the time since the order was placed (sec)
## [param par_time]: the expected time for the pizza (sec)
## [param price]: the base price of the pizza
static func get_payout(temp: float, goal_temp: float, time: float, par_time: float, price: float) -> int:
	assert(par_time > 0.0, "Cannot calculate score with par time of " + str(par_time) + " seconds!")
	var temp_difference := absf(temp - goal_temp)
	var time_ratio := time / par_time
	var temp_multiplier := exp(-pow(temp_difference / TEMPERATURE_TOLERANCE, 2.0))
	var time_multiplier := exp(-(time_ratio - 1.0))
	# The customer will only pay in whole dollars (or whatever currency we're using)
	var total_payment := roundi(BASE_TIP * temp_multiplier * time_multiplier * price)
	# But the cost of the pizza doesn't go to the player (it goes to the store)
	# So the player only gets the tip
	return maxi(0, total_payment - price)

## Gives the player this amount
static func earn_money(amount: int) -> void:
	player_gold += amount
