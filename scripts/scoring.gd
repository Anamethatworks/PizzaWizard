extends Object
class_name Score
## Class for score (should be globally loaded)


## A class for a cash bonus the player can get for getting a high enough average score
class ScoreCashBonus extends Object:
	var min_average_score: float ## The score threshold for the order
	var earned := false
	var min_total_orders: int # So the player doesn't earn every bonus on their first delivery 
	var bonus_amount: int ## The amount of money the player gets from this bonus
	func _init(threshold: float, min_orders: int, payout: int) -> void:
		min_average_score = threshold
		min_total_orders = min_orders
		bonus_amount = payout
	## Tests if the requirements for this bonus have been met
	func test_requirements_met() -> bool:
		if Score.orders_completed == 0:
			return 0
		return (float(Score.player_score / Score.orders_completed) >= min_average_score) and \
		(Score.orders_completed >= min_total_orders)
	## Gives the player the reward money and marks the bonus as earned
	func earn_bonus() -> void:
		assert(not earned, "Tried to earn the same bonus twice")
		Money.earn_money(bonus_amount)
		earned = true
		free()


## How tolerant the score function is of temperature difference
## High -> The temperature can be far from the goal temperature and still get decent points
## Low  -> The temperature has to be extremely close to the goal to avoid being heavily penalized
const TEMPERATURE_TOLERANCE: float = 10.0

## The score the player will get if they deliver at the perfect temp
## at exactly the par time
const BASE_SCORE: int = 100

## The player's score
static var player_score: int = 0

## How many orders the player has completed
static var orders_completed: int = 0

## A list of all the available bonuses that can be earned. (TODO: Balance them)
## NOTE: The earliest (lowest score threshold) should be at the end of the list, not the front!
static var bonuses: Array[ScoreCashBonus] = [
	ScoreCashBonus.new(80.0, 5, 75),
	ScoreCashBonus.new(40.0, 3, 50)
]


## If this script is autoloaded, this function can be called from anywhere using [method Score.get_score()]
## [param temp]: the temperature of the pizza
## [param goal_temp]: the temperature the customer wants it
## [param time]: the time since the order was placed (sec)
## [param par_time]: the expected time for the pizza (sec)
static func get_score(temp: float, goal_temp: float, time: float, par_time: float) -> int:
	assert(par_time > 0.0, "Cannot calculate score with par time of " + str(par_time) + " seconds!")
	var temp_difference := absf(temp - goal_temp)
	var time_ratio := time / par_time
	var temp_multiplier := exp(-pow(temp_difference / TEMPERATURE_TOLERANCE, 2.0)) # Bell curve
	var time_multiplier := 3.0 - 2.0 * time_ratio if time <= par_time else pow(time_ratio, -2.0)
	# If the player beats the par time, the time_multiplier is a linear function that gives them up to 3x
	# Otherwise, it uses time_ratio^-2 (So if the player finishes in twice the par time, they get 0.25x points)
	return roundi(BASE_SCORE * temp_multiplier * time_multiplier)



## Earns any bonuses available (Call this whenever the player reaches the pizzeria)
static func earn_bonuses() -> void:
	if bonuses[len(bonuses) - 1].test_requirements_met():
		bonuses.pop_back().earn_bonus()
	
