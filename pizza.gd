extends Object
class_name Pizza
## Class for pizzas

## The current temperature of the pizza
var temperature: float

const START_TEMPERATURE: float = 200.0

func _init() -> void:
	temperature = START_TEMPERATURE

func process_temperature(ambient_temperature: float, delta_time: float) -> void:
	temperature += Temperature.get_delta_temperature(temperature, ambient_temperature, delta_time)
