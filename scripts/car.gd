extends VehicleBody3D

#region car parameters
# Parameters that can be tweaked to change the feel of the car
static var ENGINE_MAX_FORCE: float: ## The max force of the engine (in N)
	get: return UpgradeList.ENGINE_MAX_FORCE.value
static var MAX_STEERING_ANGLE: float: ## The max angle of steering (in radians)
	get: return UpgradeList.MAX_STEERING_ANGLE.value
static var THROTTLE_SPEED: float: ## How quickly the engine reaches its max speed (in N/s)
	get: return UpgradeList.THROTTLE_SPEED.value

const BRAKE_MAX_FORCE: float = 250.0 ## The max force of the brakes (in N)
const STEERING_SPEED: float = 10.0 ## How fast the the wheels turn to the target angle (as a ratio/second)
const BRAKE_SPEED: float = 100.0 ## How quickly the brake reaches its max force (in N/s)

# NOTE: For the car to feel better while driving, these can be different than the actual car model
@onready var track_front: float = absf($WheelFR.position.x - $WheelFL.position.x)
@onready var track_rear: float = absf($WheelBR.position.x - $WheelBL.position.x)
@onready var front_wheel_base: float = ($WheelFR.position.z + $WheelFL.position.z) * -0.5
@onready var rear_wheel_base: float = ($WheelBR.position.z + $WheelBL.position.z) * 0.5

#endregion


var previous_longitudinal_velocity: float = 0.0 ## The longitudinal velocity last frame (m/s)
var previous_lateral_velocity: float = 0.0 ## The lateral velocity last frame (m/s)

var longitudinal_acceleration: float = 0.0 ## Calculated longitudinal acceleration (m/s/s)
var lateral_acceleration: float = 0.0 ## Calculated lateral acceleration (m/s/s)


var steering_angle: float = 0.0 ## Current steering angle (radians)

var Moving = 0

var CurrentTempZone = 72

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	## The minimum longitudinal velocity for the car controller
	## To begin accelerating in the opposite direction instead of braking
	Moving = 0
	const MIN_BRAKE_VELOCITY: float = 10.0
	
	var longitudinal_velocity := -cos(global_rotation.y) * linear_velocity.z - sin(global_rotation.y) * linear_velocity.x
	var lateral_velocity      := -sin(global_rotation.y) * linear_velocity.z + cos(global_rotation.y) * linear_velocity.x

	#region throttle control
	if Input.is_action_pressed("MoveForward") and Input.is_action_pressed("MoveBackward"):
		Moving = 1
		set_engine_force(move_toward(get_engine_force(), 0.5 * ENGINE_MAX_FORCE, THROTTLE_SPEED * delta))
		set_brake(move_toward(get_brake(), BRAKE_MAX_FORCE * 0.5, BRAKE_SPEED * delta))
	elif Input.is_action_pressed("MoveForward"):
		Moving = 1
		if longitudinal_velocity < -MIN_BRAKE_VELOCITY:
			set_engine_force(0.0)
			set_brake(move_toward(get_brake(), BRAKE_MAX_FORCE, BRAKE_SPEED * delta))
		else:
			set_brake(0.0)
			set_engine_force(move_toward(get_engine_force(), ENGINE_MAX_FORCE, THROTTLE_SPEED * delta))
	elif Input.is_action_pressed("MoveBackward"):
		Moving = 1
		if longitudinal_velocity > MIN_BRAKE_VELOCITY:
			set_engine_force(0.0)
			set_brake(move_toward(get_brake(), BRAKE_MAX_FORCE, BRAKE_SPEED * delta))
		else:
			set_brake(0.0)
			set_engine_force(move_toward(get_engine_force(), -ENGINE_MAX_FORCE, THROTTLE_SPEED * delta))
	else:
		set_brake(0.0)
		set_engine_force(move_toward(get_engine_force(), 0.0, THROTTLE_SPEED * delta))
	#endregion

	#region Sound FX
	
	if Input.is_action_just_pressed("Honk"):
		$SoundController/HonkSound.play()
		
	if engine_force == 0.0:
		$SoundController/DrivingSound.stream_paused = true
	else:
		$SoundController/DrivingSound.stream_paused = false
		$SoundController/DrivingSound.volume_db = log(absf(engine_force) / ENGINE_MAX_FORCE) / log(10.0)
	
	#endregion
	
	set_steering(move_toward(get_steering(), Input.get_axis("MoveRight", "MoveLeft") * MAX_STEERING_ANGLE, STEERING_SPEED * delta))

	# Turn steering, depending on left/right player input
	steering_angle = move_toward(steering_angle, Input.get_axis("MoveRight", "MoveLeft") * MAX_STEERING_ANGLE, STEERING_SPEED * delta)
	
	calculate_ackermann_steering(steering_angle) # Turn the actual wheels
	calc_acceleration(longitudinal_velocity, lateral_velocity, delta) # Calculate acceleration to use in later functions
	distribute_weight() # Transfer car weight between wheels
	calculate_wheel_velocities(longitudinal_velocity, lateral_velocity) # Calculate the local velocities of each wheel
	apply_wheel_slip() # Apply forces based on each tire's slip and grip
	
	flip_failsafe()
	
	previous_longitudinal_velocity = longitudinal_velocity
	previous_lateral_velocity = lateral_velocity


## If the player flips, turn the car back over
func flip_failsafe() -> void:
	if absf(global_rotation.x) >= PI / 2.0:
		global_rotation.x = 0.0
		angular_velocity.x = 0.0
		global_position.y += 1.0
	if absf(global_rotation.z) >= PI / 2.0:
		global_rotation.z = 0.0
		angular_velocity.z = 0.0
		global_position.y += 1.0

## Calculates the longitudinal and lateral acceleration
func calc_acceleration(long_velocity: float, lat_velocity: float, delta: float) -> void:
	longitudinal_acceleration = (long_velocity - previous_longitudinal_velocity) / delta
	lateral_acceleration = (lat_velocity - previous_lateral_velocity) / delta


## Applies the needed forces to dynamically distribute the car's weight to the tires
func distribute_weight() -> void:
	calculate_weight_transfer_symmetrical_tracks(longitudinal_acceleration * mass, lateral_acceleration * mass)
	apply_central_force(Vector3(0.0, -get_gravity().y * get_gravity_scale() * mass, 0.0))
	apply_force(Vector3(0.0, -$WheelFR.wheel_load, 0.0), $WheelFR.global_position - self.global_position)
	apply_force(Vector3(0.0, -$WheelBR.wheel_load, 0.0), $WheelBR.global_position - self.global_position)
	apply_force(Vector3(0.0, -$WheelBL.wheel_load, 0.0), $WheelBL.global_position - self.global_position)
	apply_force(Vector3(0.0, -$WheelFL.wheel_load, 0.0), $WheelFL.global_position - self.global_position)


## Calculate the amount of weight on each wheel, given a lateral and longitudinal acceleration
## NOTE: If the track_rear and track_front are equal, the formulae can be simplified
## Then, use calculate_weight_transfer_symmetrical_tracks() instead
func calculate_weight_transfer(longitudinal_force: float, lateral_force: float) -> void:
	# SOURCE: "The Physics of Racing, Part 27: Four-Wheel Weight Transfer" by Brian Beckman, PhD
	# http://autoxer.skiblack.com/phys_racing/phors27.htm
	
	var h := get_center_of_mass().y
	var W := -get_gravity().y * get_gravity_scale() * mass
	if W == 0:
		return
	var a := front_wheel_base
	var b := rear_wheel_base
	var t_r := track_rear * 0.5
	var t_f := track_front * 0.5
	var Fx := longitudinal_force * h
	var Fy := lateral_force * h
	
	$WheelFR.wheel_load = 0.5 * (Fx - b * W) * (-1.0 / (a + b) + Fy / (Fx * (t_r - t_f) + W * (b * t_f + a * t_r)))
	$WheelBR.wheel_load = 0.5 * (Fx + a * W) * ( 1.0 / (a + b) - Fy / (Fx * (t_r - t_f) + W * (b * t_f + a * t_r)))
	$WheelBL.wheel_load = 0.5 * (Fx + a * W) * ( 1.0 / (a + b) + Fy / (Fx * (t_r - t_f) + W * (b * t_f + a * t_r)))
	$WheelFL.wheel_load = 0.5 * (Fx - b * W) * (-1.0 / (a + b) - Fy / (Fx * (t_r - t_f) + W * (b * t_f + a * t_r)))

## The same as calculate_weight_transfer(), but uses some shortcuts that can only be done if track_rear and track_front are equal
## If track_rear and track_front differ, use the other function. Otherwise, this one is less computationally expensive
func calculate_weight_transfer_symmetrical_tracks(longitudinal_force: float, lateral_force: float) -> void:
	assert(track_front == track_rear, "Different front and rear tracks! Use calculate_weight_transfer() instead!")
	var h := get_center_of_mass().y
	var W := -get_gravity().y * get_gravity_scale() * mass
	if W == 0:
		return
	var a := front_wheel_base
	var b := rear_wheel_base
	var t := track_front * 0.5 * W
	var Fx := longitudinal_force * h
	var Fy := lateral_force * h
	
	$WheelFR.wheel_load = 0.5 * (Fx - b * W) * (-1.0 + Fy / t) / (a + b)
	$WheelBR.wheel_load = 0.5 * (Fx + a * W) * ( 1.0 - Fy / t) / (a + b)
	$WheelBL.wheel_load = 0.5 * (Fx + a * W) * ( 1.0 + Fy / t) / (a + b)
	$WheelFL.wheel_load = 0.5 * (Fx - b * W) * (-1.0 - Fy / t) / (a + b)
	
	



func _on_body_entered(body: Node) -> void:
	if body.get_parent().name == "CrashType":
		var impulse := Vector2(previous_lateral_velocity, previous_longitudinal_velocity).length()
		$SoundController/CrashSound.play()
		$SoundController/CrashSound.volume_db = log(impulse * 0.1) - 10.0
		
	
	#if body.get  #get_parent().name == "Building01":
		#$SoundController/CrashSound.play()


## Turns the left and right front wheels to account for ackermann steering geometry
## (The left and right wheels have to turn to slightly different angles)
## Supply it with a base angle in radians
# https://en.wikipedia.org/wiki/Ackermann_steering_geometry
func calculate_ackermann_steering(base_angle: float) -> void:
	if base_angle == 0.0:
		$WheelFR.set_steering(0.0)
		$WheelFR.steer_test = 0.0
		$WheelFL.set_steering(0.0)
		$WheelFL.steer_test = 0.0
	var turning_radius := (front_wheel_base + rear_wheel_base) / tan(base_angle)
	
	$WheelFR.set_steering(atan((front_wheel_base + rear_wheel_base) / (turning_radius - track_front)))
	$WheelFR.steer_test = atan((front_wheel_base + rear_wheel_base) / (turning_radius - track_front))
	$WheelFL.set_steering(atan((front_wheel_base + rear_wheel_base) / (turning_radius + track_front)))
	$WheelFL.steer_test = atan((front_wheel_base + rear_wheel_base) / (turning_radius + track_front))
	

## Calculates and sets each wheel's local_velocity
func calculate_wheel_velocities(long_vel: float, lat_vel: float) -> void:
	var base_velocity := Vector2(lat_vel, long_vel)
	$WheelFR.local_velocity = base_velocity + get_local_velocity_at_point(Vector2(track_front *  0.5, -front_wheel_base))
	$WheelBR.local_velocity = base_velocity + get_local_velocity_at_point(Vector2(track_rear  *  0.5,  rear_wheel_base))
	$WheelBL.local_velocity = base_velocity + get_local_velocity_at_point(Vector2(track_rear  * -0.5,  rear_wheel_base))
	$WheelFL.local_velocity = base_velocity + get_local_velocity_at_point(Vector2(track_front * -0.5, -front_wheel_base))

## Accounts for rotation to get the instantaneous velocity at a point
## NOTE: Does not include the car's linear velocity, which must be added
func get_local_velocity_at_point(point: Vector2) -> Vector2:
	var radius := sqrt(point.x * point.x + point.y * point.y)
	var omega := angular_velocity.y
	var angle_offset := atan2(point.y, point.x)
	return omega * radius * Vector2(-sin(angle_offset), cos(angle_offset))

## Applies the forces of wheel slip for each tire
func apply_wheel_slip() -> void:
	var FR: Vector2 = $WheelFR.slip_and_grip()
	var BR: Vector2 = $WheelBR.slip_and_grip()
	var BL: Vector2 = $WheelBL.slip_and_grip()
	var FL: Vector2 = $WheelFL.slip_and_grip()
	
	apply_force(Vector3(FR.x, 0.0, -FR.y).rotated(global_basis.y, global_rotation.y + $WheelFR.steering), $WheelFR.global_position - self.global_position)
	apply_force(Vector3(BR.x, 0.0, -BR.y).rotated(global_basis.y, global_rotation.y + $WheelBR.steering), $WheelBR.global_position - self.global_position)
	apply_force(Vector3(BL.x, 0.0, -BL.y).rotated(global_basis.y, global_rotation.y + $WheelBL.steering), $WheelBL.global_position - self.global_position)
	apply_force(Vector3(FL.x, 0.0, -FL.y).rotated(global_basis.y, global_rotation.y + $WheelFL.steering), $WheelFL.global_position - self.global_position)


func _on_mid_temp_parent_area_entered(area: Area3D) -> void:
	print("MidCheck")
	#dprint(SceneTree.get_nodes_in_group("MidZone"))
	if area.is_in_group("MidZone"):
		CurrentTempZone = 72
		print("Mid", CurrentTempZone)


func _on_cold_temp_parent_area_entered(area: Area3D) -> void:
	print("ColdCheck")
	if area.is_in_group("ColdZone"):
		CurrentTempZone = 32
		print("Cold", CurrentTempZone)


func _on_hot_temp_parent_area_entered(area: Area3D) -> void:
	print("HotCheck")
	if area.is_in_group("HotZone"):
		CurrentTempZone = 112
		print("Hot", CurrentTempZone)
