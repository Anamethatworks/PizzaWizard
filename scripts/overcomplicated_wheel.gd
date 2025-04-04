class_name BetterWheel extends VehicleWheel3D

var wheel_load: float = 0.0 # The load the tire is supporting (in N)
var local_velocity := Vector2.ZERO # The velocity of the tire with respect to the ground
var steer_test: float = 0.0 # Slip breaks if I use the actual steering value, but it works if I use this
# If anyone can figure out why, please let me know -Sophie

@onready var MASS: float = get_parent().mass

var previous_force := Vector2.ZERO ## The force applied last frame

## Reduces some of the previous force from the velocity used for calculation
## So slip doesn't cause a feedback loop
## Kind of hacky, but it makes the car less slidy (when it's not supposed to be slidy)
func ignore_feedback_slip() -> void:
	var accel: Vector2 = previous_force * wheel_load / MASS
	if local_velocity.x > 0.0:
		local_velocity.x = maxf(local_velocity.x - maxf(accel.x, 0.0), 0.0)
	elif local_velocity.x < 0.0:
		local_velocity.x = minf(local_velocity.x - minf(accel.x, 0.0), 0.0)
		
	if local_velocity.y > 0.0:
		local_velocity.y = maxf(local_velocity.y - maxf(accel.y, 0.0), 0.0)
	elif local_velocity.y < 0.0:
		local_velocity.y = minf(local_velocity.y - minf(accel.y, 0.0), 0.0)

## Calculates the longitudinal/lateral forces caused by wheel slip
func slip_and_grip() -> Vector2:
	ignore_feedback_slip()
	if not is_in_contact() or wheel_load < 0.0:
		previous_force = Vector2.ZERO
		return Vector2.ZERO
	
	var slip_velocity := get_slip_velocity()
	if slip_velocity == Vector2.ZERO:
		previous_force = Vector2.ZERO
		return Vector2.ZERO
	
	const  SLIP_SCALE_FACTOR: float = 0.0796
	const ANGLE_SCALE_FACTOR: float = 3.273
	var normal_slip  := slip_velocity.x / SLIP_SCALE_FACTOR
	var normal_angle := slip_velocity.y / ANGLE_SCALE_FACTOR
	var rho := sqrt(normal_slip * normal_slip + normal_angle * normal_angle)
	
	
	var y := normal_slip  / rho * pacejka_magic_formula_longitudinal(rho * SLIP_SCALE_FACTOR)
	var x := normal_angle / rho * pacejka_magic_formula_lateral(rho * ANGLE_SCALE_FACTOR)
	
	set_friction_slip(10.5)
	var terrain := get_contact_body()
	if is_instance_valid(terrain):
		if terrain is StaticBody3D:
			if is_instance_valid(terrain.physics_material_override):
				var friction: float = terrain.physics_material_override.friction
				x *= friction
				y *= friction
				set_friction_slip(friction * 10.5)
	
	previous_force = Vector2(x, y)
	return Vector2(x, y)
	
## A simplified version of Pacejka's magic formula for longitudinal tire slip
func pacejka_magic_formula_longitudinal(slip: float) -> float:
	# Taken from "The Physics of Racing, Part 21: The Magic Formula: Longitudinal Version"
	# http://autoxer.skiblack.com/phys_racing/phors21.htm
	# MAGIC CONSTANTS, HAVE NO PHYSICAL REPRESENTATION
	const b0: float = 1.65
	const b2: float = 1688.0
	const b4: float = 229.0
	const b8: float = -10.0
	const mu_p := b2
	const B := b4 / (b0 * mu_p)
	var D := mu_p * wheel_load * 0.001
	var S := 100.0 * slip
	const E := b8
	var SB := S * B
	return D * sin(b0 * atan(SB - E * (SB - atan(SB))))

## A simplified version of Pacejka's magic formula for lateral tire slip
func pacejka_magic_formula_lateral(angle: float) -> float:
	# Taken from "The Physics of Racing, Part 22: The Magic Formula: Lateral Version"
	# http://autoxer.skiblack.com/phys_racing/phors22.htm
	# MAGIC CONSTANTS, HAVE NO PHYSICAL REPRESENTATION
	const a0:  float = 1.799
	const a2:  float = 1688.0
	const a3:  float = 4140.0
	const a4:  float = 6.026
	const a6:  float = -0.3589
	const a7:  float = 1.0
	const a9:  float = -0.006111
	const a10: float = -0.03224
	const mu_p := a2
	var D := mu_p * wheel_load * 0.001
	var S := angle + a9 * wheel_load * 0.001 + a10
	var B := 1000.0 * a3 * sin(2.0 * atan(wheel_load * 0.001 / a4)) / (a0 * mu_p * wheel_load)
	var E := a6 * wheel_load * 0.001 + a7
	var SB := S * B
	return D * sin(a0 * atan(SB + E * (atan(SB) - SB)))

## Returns a Vector2 of:
## x: The wheel slip
## y: The wheel slip angle
func get_slip_velocity() -> Vector2:
	# Inspired by Brian Beckman's "The Physics of Racing, Part 24: Combination Slip"
	# http://autoxer.skiblack.com/phys_racing/phors24.htm
	var theoretical_velocity := -get_rpm() * TAU / 60.0 * wheel_radius
	var slip: float = 0.0 if (local_velocity.length_squared() < 0.01) else (theoretical_velocity - local_velocity.y) / local_velocity.length()
	
	#if absf(local_velocity.y) < 1.00: # Low velocity failsafe (So the car doesn't shake at rest)
		#slip *= 0.01
	
	var tire_velocity: Vector2 = Vector2(local_velocity.y, local_velocity.x).rotated(-steering)
	var slip_angle: float = atan2(tire_velocity.y, tire_velocity.x)
	slip_angle = rad_to_deg(slip_angle)
	while slip_angle > 90.0:
		slip_angle -= 180.0
	while slip_angle < -90.0:
		slip_angle += 180.0
	
	# Manual hack to reduce lateral slip, especially when car is moving slowly
	slip_angle *= sigmoid(absf(local_velocity.x) * 0.01)
	
	return Vector2(slip, slip_angle)
	
## A simple sigmoid function for smoothly restricting an input
static func sigmoid(x: float) -> float:
	return x / sqrt(1.0 + x * x)
