extends Object
class_name Pizza
## Class for pizzas

## The current temperature of the pizza
var temperature: float

func _init(starting_temp: float) -> void:
	temperature = starting_temp

func process_temperature(ambient_temperature: float, delta_time: float) -> void:
	temperature += Temperature.get_delta_temperature(temperature, ambient_temperature, delta_time)
