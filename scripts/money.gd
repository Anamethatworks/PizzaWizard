extends Object
class_name Money
## Class for money and calculating payout (should be globally loaded)

## How tolerant the payment function is of temperature difference
const TEMPERATURE_TOLERANCE: float = 27.0
## The default amount the customer will tip
const BASE_TIP: float = 0.1

## The money the player has
static var player_gold: int = 1000

## If this script is autoloaded, this function can be called from anywhere using [method Money.get_payout()]
## [param temp]: the temperature of the pizza
## [param goal_temp]: the temperature the customer wants it
## [param time]: the time since the order was placed (sec)
## [param par_time]: the expected time for the pizza (sec)
## [param price]: the base price of the pizza
static func get_payout(temp: float, goal_temp: float, time: float, par_time: float, price: float) -> int:
	assert(par_time > 0.0, "Cannot calculate score with par time of " + str(par_time) + " seconds!")
	var temp_difference := goal_temp - temp
	if temp_difference < 0:
		temp_difference = 0
	var time_ratio := time / par_time
	var temp_multiplier := exp(-pow(temp_difference / TEMPERATURE_TOLERANCE, 2.0))
	var time_multiplier := exp(-(time_ratio - 1.0))
	var total_payment := roundi(BASE_TIP * temp_multiplier * time_multiplier * price)
	return maxi(0, total_payment)

## Gives the player this amount
static func earn_money(amount: int) -> void:
	player_gold += amount
