extends Object
class_name Temperature
## Class for temperature (should be globally loaded)

## Gets by how much the temperature should change every frame
## [param pizza_temperature]: the current temperature of the pizza
## [param ambient_temperature]: the temperature of the atmosphere the pizza is in
## [param delta_time]: [method Node._process()]'s [param delta]
static func get_delta_temperature(pizza_temperature: float, ambient_temperature: float, delta_time: float) -> float:
	## How fast the temperature changes to match the ambient temperature
	## It denotes how much the temperature should change in one second.
	## =0.0 => The temperature doesn't change
	## =0.0057595762 => The pizza takes 120 seconds to get halfway to the ambient temperature
	## =0.0114859796 => The pizza takes 60 seconds to get halfway to the ambient temperature
	## =0.5 => The pizza takes 1 second to get halfway to the ambient temperature
	const TEMP_CHANGE_SPEED: float = 0.0114859796
	return (ambient_temperature - pizza_temperature) * (1.0 - pow(1.0 - TEMP_CHANGE_SPEED, delta_time))
	
