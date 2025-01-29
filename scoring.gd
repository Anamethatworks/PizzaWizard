extends Object
class_name Score

const TEMPERATURE_TOLERANCE: float = 10.0 # How tolerant the score function is of temperature difference
# High -> The temperature can be far from the goal temperature and still get decent points
# Low  -> The temperature has to be extremely close to the goal to avoid being heavily penalized

const BASE_SCORE: int = 100 # The score the player will get if they deliver at the perfect temp
# at exactly the par time

const MINIMUM_SCORE: int = 10

# If this script is autoloaded, this function can be called from anywhere using Score.get_score()
# temp: the temperature of the pizza
# goal_temp: the temperature the customer wants it
# time: the time since the order was placed (sec)
# par_time: the expected time for the pizza (sec)
static func get_score(temp: float, goal_temp: float, time: float, par_time: float) -> int:
	assert(par_time > 0.0, "Cannot calculate score with par time of " + str(par_time) + " seconds!")
	var temp_difference := absf(temp - goal_temp)
	var time_ratio := time / par_time
	var temp_multiplier := exp(-pow(temp_difference / TEMPERATURE_TOLERANCE, 2.0)) # Bell curve
	var time_multiplier := 3.0 - 2.0 * time_ratio if time <= par_time else pow(time_ratio, -2.0)
	# If the player beats the par time, the time_multiplier is a linear function that gives them up to 3x
	# Otherwise, it uses time_ratio^-2 (So if the player finishes in twice the par time, they get 0.25x points)
	return roundi((BASE_SCORE - MINIMUM_SCORE) * temp_multiplier * time_multiplier) + MINIMUM_SCORE
