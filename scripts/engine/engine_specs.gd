@tool class_name EngineSpecs extends Resource
## Class for specifying a type of engine

## Enum for traditional piston setups. The simulator can handle other piston setups,
## But those would have to be created
enum Setup {
	STRAIGHT, # In-line engine
	VEE, # V engine
	RADIAL #Radial engine
}

@export var setup: Setup = Setup.STRAIGHT
@export_range(1, 32, 1, "hide_slider", "or_greater") var pistons: int = 4




static var setup_function: Dictionary[Setup, Callable] = {
	Setup.STRAIGHT: setup_straight_engine,
	Setup.VEE: setup_v_engine,
	Setup.RADIAL: setup_radial_engine
}

func setup_general() -> Crankshaft:
	return setup_function[setup].call(pistons)

static func setup_straight_engine(piston_count: int) -> Crankshaft:
	var pins: Array[Crankpin] = []
	for i: int in range(piston_count):
		pins.append(Crankpin.new([Piston.new()]))
	var shaft := Crankshaft.new(pins)
	return shaft

static func setup_v_engine(piston_count: int) -> Crankshaft:
	assert(piston_count % 2 == 0, "Odd-numbered piston counts are not supported for v type engines")
	var pins: Array[Crankpin] = []
	for i: int in range(0, piston_count, 2):
		pins.append(Crankpin.new([Piston.new(), Piston.new()]))
	var shaft := Crankshaft.new(pins)
	return shaft
	return shaft
	
static func setup_radial_engine(piston_count: int) -> Crankshaft:
	var piston_list: Array[Piston] = []
	for i: int in range(piston_count):
		piston_list.append(Piston.new())
	var shaft := Crankshaft.new([Crankpin.new(piston_list)])
	return shaft
