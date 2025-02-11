extends CharacterBody3D

## DEPRECATED!!!
## I'm just keeping this file because I kept so many equations in here

# I went fully down the driving physics rabbit hole
# Many equations taken from or derived from the contents of "The Physics of Racing" by Brian Beckman
# http://autoxer.skiblack.com/phys_racing/contents.htm

enum mode {FWD, RWD, AWD}

const VEHICLE_MODE := mode.FWD

const GRAVITY_ACCELERATION: float = 9.8067

## Mass of the car in kilograms
@export var mass: float = 1600.0

var wheelbase: float = 3.1 ## Distance between the front and rear axle, in meters
var track: float = 1.27 ## Distance between the left and right wheels, in meters
var cg_height: float = 0.8 ## Height of the center of gravity, in meters

var front_wheel_weight_proportion: float = 0.5 ## Proportion of the car's weight on the front tires

## Rolling Resistance Coffecient. For realism, rubber and concrete is between 0.0100 - 0.0150
const WHEEL_FRICTION_ROLLING: float = 0.0125

## Coffecient of friction (static). For realism, rubber and concrete is about 1.1
const WHEEL_FRICTION_STATIC: float = 1.1

## Coffecient of friction (kinetic). For realism, rubber and concrete is between 0.6 - 0.85 
const WHEEL_FRICTION_SLIDING: float = 0.725
# NOTE: The coefficients of friction for WET concrete and rubber are 0.3 and 0.45-0.75, so using this instead
# would simulate driving on a wet road

const AIR_DRAG_COEFFICIENT: float = 0.3

## Frontal surface area, in m^2
const FRONTAL_SURFACE_AREA: float = 1.86

## Air density, in grams per liter
const AIR_DENSITY: float = 0.00129

const REAR_END_RATIO: float = 3.07

const WHEEL_DIAMETER: float = 0.663

## How fast the wheels turn when the player uses the a/d keys
const STEERING_SPEED: float = 1.0

const GEAR_RATIO_FIRST: float = 2.88
const GEAR_RATIO_SECOND: float = 1.91
const GEAR_RATIO_THIRD: float = 1.33
const GEAR_RATIO_FOURTH: float = 1.00

const ROLL_RESISTANCE_FACTOR: float = 10.1573564551 ## Newtons per (meters per second)

const ENGINE_TORQUE: float = 447.41992294 ## torque, in newton-meters

class Tire:
	var angle: float = 0.0 ## Angle of the tire relative to car body, in radians
	var lift_force: float = 0.0 ## Lift force of the ground on the tire, in newtons
	var base_weight_proportion: float = 0.25 ## How much of the weight of the car applies to this tire when the car is at rest
	const MAX_ADHESIVE_ACCELERATION: float = GRAVITY_ACCELERATION ## Max acceleration the tire can handle before sliding
	var sliding := false
		
	func get_max_adhesive_limit() -> float:
		return lift_force * WHEEL_FRICTION_STATIC
	

#region tires
# I create this class and variable just so I can use the notation tires.fr to access each one
# I'd use a dictionary, but I can't statically type the keys
class Tires:
	var fr := Tire.new()
	var fl := Tire.new()
	var br := Tire.new()
	var bl := Tire.new()

var tires := Tires.new()
#endregion

var gear: int = 1
var longitudinal_velocity: float = 0.0
var lateral_velocity: float = 0.0

var throttle: float = 0.0
var brake := false

const THROTTLE_MOVE_SPEED: float = 1.0

var steering: float = 0.0


func _physics_process(delta: float) -> void:
	## The 2d velocity relative to the car
	var local_velocity := get_local_vector(velocity.x, velocity.z)
	longitudinal_velocity = local_velocity.y
	lateral_velocity = local_velocity.x
	
	## The minimum longitudinal velocity for the car controller
	## To begin accelerating in the opposite direction instead of braking
	const MIN_COUNTERACCELERATION_VELOCITY: float = 1.0
	#region throttle control
	if longitudinal_velocity > 0.0:
		# Moving forwards
		if Input.is_action_pressed("MoveForward"):
			throttle = move_toward(throttle, 1.0, THROTTLE_MOVE_SPEED * delta)
			check_shift_up_gear(longitudinal_velocity)
			brake = Input.is_action_pressed("MoveBackward")
		elif Input.is_action_pressed("MoveBackward"):
			if longitudinal_velocity < MIN_COUNTERACCELERATION_VELOCITY:
				gear = -1
			throttle = 0.0
			brake = true
		else:
			brake = false
			throttle = move_toward(throttle, 0.0, THROTTLE_MOVE_SPEED * delta)
	elif longitudinal_velocity < 0.0:
		# Moving backwards
		if Input.is_action_pressed("MoveBackward"):
			throttle = move_toward(throttle, 1.0, THROTTLE_MOVE_SPEED * delta)
			brake = Input.is_action_pressed("MoveForward")
		elif Input.is_action_pressed("MoveForward"):
			if longitudinal_velocity > -MIN_COUNTERACCELERATION_VELOCITY:
				gear = 1
			throttle = 0.0
			brake = true
		else:
			brake = false
			throttle = move_toward(throttle, 0.0, THROTTLE_MOVE_SPEED * delta)
	#endregion

	steering = move_toward(steering, Input.get_axis("MoveLeft", "MoveRight"), STEERING_SPEED * delta)
	
	# Update tire angles
	
	
	var global_velocity := get_global_vector(local_velocity.x, local_velocity.y)
	velocity.x = global_velocity.x
	velocity.z = global_velocity.y
	
	
	move_and_slide()

func get_local_vector(x: float, z: float) -> Vector2:
	return Vector2(-sin(rotation.y) * velocity.z + cos(rotation.y) * velocity.x, -cos(rotation.y) * velocity.z - sin(rotation.y) * velocity.x)

func get_global_vector(latitude: float, longitude: float) -> Vector2:
	return Vector2(-longitude * sin(rotation.y) + latitude * cos(rotation.y), -longitude * cos(rotation.y) - latitude * sin(rotation.y))

## Returns the car's weight in newtons
func get_weight() -> float:
	return mass * GRAVITY_ACCELERATION

## Calculates the lift force (N) for each tire based on a given net force of the car (in N)
func calculate_tire_lift_force(long_force: float, lat_force: float) -> void:
	var helper1 := 0.5 / wheelbase
	var helper2 := wheelbase * get_weight() * 0.5
	var helper3 := long_force * cg_height
	var helper4 := 2.0 * lat_force * cg_height / (get_weight() * track)
	tires.fr.lift_force = helper1 * (helper2 - helper3) * (1.0 + helper4)
	tires.br.lift_force = helper1 * (helper2 + helper3) * (1.0 + helper4)
	tires.bl.lift_force = helper1 * (helper2 + helper3) * (1.0 - helper4)
	tires.fl.lift_force = helper1 * (helper2 - helper3) * (1.0 - helper4)
	

## Returns the force of frontal air resistance, in newtons
func get_air_resistance(vel: float) -> float:
	return 0.5 * AIR_DRAG_COEFFICIENT * FRONTAL_SURFACE_AREA * AIR_DENSITY * pow(vel, 2.0)

func get_rolling_resistance(vel: float) -> float:
	return ROLL_RESISTANCE_FACTOR * vel

func get_engine_rpm(vel: float) -> float:
	return 60.0 * vel / (PI * WHEEL_DIAMETER) * throttle

func get_gear_ratio(selected_gear: int) -> float:
	const RATIO_ARRAY: PackedFloat32Array = [-GEAR_RATIO_FIRST, 0.0, GEAR_RATIO_FIRST, GEAR_RATIO_SECOND, GEAR_RATIO_THIRD, GEAR_RATIO_FOURTH]
	return RATIO_ARRAY[selected_gear + 1]
	
func check_shift_up_gear(vel: float) -> void:
	const MAX_RPM := 4200
	if get_engine_rpm(vel) * get_gear_ratio(gear) * REAR_END_RATIO > MAX_RPM:
		if gear < 4:
			gear += 1

func check_shift_down_gear(vel: float) -> void:
	const MAX_RPM := 4200
	if gear > 1:
		if get_engine_rpm(vel) * get_gear_ratio(gear - 1) * REAR_END_RATIO < MAX_RPM:
			gear -= 1

func get_net_forward_force(vel: float) -> float:
	return get_wheel_forward_force() - get_air_resistance(vel) - get_rolling_resistance(vel)

func get_wheel_forward_force() -> float:
	return ENGINE_TORQUE * REAR_END_RATIO * get_gear_ratio(gear) / (WHEEL_DIAMETER * 0.5)
