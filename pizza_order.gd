extends Object
class_name Order
## A class for an order that the player can fulfill.

## The [DropoffPoint] the player must deliver this pizza to
var dropoffPoint: DropoffPoint
## The pizza that corresponds to this order
var ordered_pizza: Pizza = null
## The expected time for the player to deliver the pizza
var parTime: float
## The temperature the customer wants the pizza at
var goalTemperature: float
## The price of the order (not how much the player will get as payment)
var price: float

func _init(location: DropoffPoint, par_time: float) -> void:
	dropoffPoint = location
	parTime = par_time
	
	# Initialize price
	const PRICE_MEAN              : float = 30.0
	const PRICE_STANDARD_DEVIATION: float = 15.0
	const PRICE_MINIMUM           : float = 10.0
	price = randfn(PRICE_MEAN, PRICE_STANDARD_DEVIATION)
	if price < PRICE_MINIMUM:
		price = PRICE_MINIMUM + absf(PRICE_MINIMUM - price)
	
	# Initialize goal temperature
	const GOAL_TEMP_MEAN              : float = 50.0
	const GOAL_TEMP_STANDARD_DEVIATION: float = 20.0
	goalTemperature = randfn(GOAL_TEMP_MEAN, GOAL_TEMP_STANDARD_DEVIATION)
	
	# Create pizza instance at pizzeria
	ordered_pizza = Pizzeria.active_location.create_pizza()
	if not is_instance_valid(ordered_pizza):
		# The pizzeria couldn't create an order (possibly because it was at
		# the max order limit), so cancel this order.
		free()

## Pays the player, gives them points, and clears the order
func fulfill(real_temp: float, real_time: float) -> void:
	var payout: float = Money.get_payout(real_temp, goalTemperature, real_time, parTime, price)
	# Give the player the money (TODO)
	var score: int = Score.get_score(real_temp, goalTemperature, real_time, parTime)
	# Give the player the score (TODO)
	
	free() # Remove the order now that it's been fulfilled

## Removes the order without giving the player money or points
func failOrder() -> void:
	# I don't know if there will be any circumstances in which the player can
	# fail an order, but I added this function just in case
	free()
