extends VehicleBody3D

const ENGINE_FORCE: float = 6000.0
const BRAKE_FORCE: float = 4400.0
const MAX_STEERING_ANGLE: float = TAU / 16.0
const THROTTLE_SPEED: float = 100000.0
const STEERING_SPEED: float = 10.0

# NOTE: For the car to feel better while driving, these can be different than the actual car model
@export var track_front: float = 1.284 ## Distance between front tires
@export var track_rear: float = 1.284 ## Distance between rear tires
@export var front_wheel_base: float = 1.549 ## Long. Distance between front axle and the center of mass
@export var rear_wheel_base: float = 1.549 ## Long. Distance between rear axle and the center of mass

func _ready() -> void:
	# Set the positions of tires based on specified tracks and wheelbase
	$WheelFR.position = Vector3(track_rear *  0.5, 0.32, -front_wheel_base)
	$WheelBR.position = Vector3(track_rear *  0.5, 0.32,   rear_wheel_base)
	$WheelBL.position = Vector3(track_rear * -0.5, 0.32,   rear_wheel_base)
	$WheelFL.position = Vector3(track_rear * -0.5, 0.32, -front_wheel_base)

func _physics_process(delta: float) -> void:	
	## The minimum longitudinal velocity for the car controller
	## To begin accelerating in the opposite direction instead of braking
	const MIN_BRAKE_VELOCITY: float = 100.0
	
	var longitudinal_velocity := -cos(rotation.y) * linear_velocity.z - sin(rotation.y) * linear_velocity.x
	
	#region throttle control
	if Input.is_action_pressed("MoveForward") and Input.is_action_pressed("MoveBackward"):
		set_engine_force(move_toward(get_engine_force(), 0.5 * ENGINE_FORCE, THROTTLE_SPEED * delta))
		set_brake(BRAKE_FORCE * 0.5)
	elif Input.is_action_pressed("MoveForward"):
		if longitudinal_velocity < -MIN_BRAKE_VELOCITY:
			set_engine_force(move_toward(get_engine_force(), 0.0, THROTTLE_SPEED * delta))
			set_brake(BRAKE_FORCE)
		else:
			set_brake(0.0)
			set_engine_force(move_toward(get_engine_force(), ENGINE_FORCE, THROTTLE_SPEED * delta))
	elif Input.is_action_pressed("MoveBackward"):
		if longitudinal_velocity > MIN_BRAKE_VELOCITY:
			set_engine_force(move_toward(get_engine_force(), 0.0, THROTTLE_SPEED * delta))
			set_brake(BRAKE_FORCE)
		else:
			set_brake(0.0)
			set_engine_force(move_toward(get_engine_force(), -ENGINE_FORCE, THROTTLE_SPEED * delta))
	else:
			set_brake(0.0)
			set_engine_force(move_toward(get_engine_force(), 0.0, THROTTLE_SPEED * delta))
	#endregion

	set_steering(move_toward(get_steering(), Input.get_axis("MoveRight", "MoveLeft") * MAX_STEERING_ANGLE, STEERING_SPEED * delta))


func calculate_weight_transfer(longitudinal_force: float, lateral_force: float) -> void:
	# SOURCE: "The Physics of Racing, Part 27: Four-Wheel Weight Transfer" by Brian Beckman, PhD
	# http://autoxer.skiblack.com/phys_racing/phors27.htm
	
	var h := center_of_mass.y + global_position.y # MAKE SURE TO SUBTRACT THE HEIGHT OF THE ROAD FROM H
	var a := front_wheel_base
	var b := rear_wheel_base
	var tr := track_rear * 0.5
	var tf := track_front * 0.5
	var Fx := longitudinal_force * h
	var Fy := lateral_force * h
	var W := -get_gravity().y * get_gravity_scale() * mass
	
	var Wfr := 0.5 * (Fx - b * W) * (-1.0 / (a + b) + Fy / (Fx * (tr - tf) + W * (b * tf + a * tr)))
	var Wbr := 0.5 * (Fx + a * W) * ( 1.0 / (a + b) - Fy / (Fx * (tr - tf) + W * (b * tf + a * tr)))
	var Wbl := 0.5 * (Fx + a * W) * ( 1.0 / (a + b) + Fy / (Fx * (tr - tf) + W * (b * tf + a * tr)))
	var Wfl := 0.5 * (Fx - b * W) * (-1.0 / (a + b) - Fy / (Fx * (tr - tf) + W * (b * tf + a * tr)))

## The same as calculate_weight_transfer(), but uses some shortcuts that can only be done if track_rear and track_front are equal
## If track_rear and track_front, use the other function. Otherwise, this one is less computationally expensive
func calculate_weight_transfer_symmetrical_tracks(longitudinal_force: float, lateral_force: float) -> void:
	assert(track_front == track_rear, "Different front and rear tracks! Use calculate_weight_transfer() instead!")
	var h := center_of_mass.y + global_position.y # MAKE SURE TO SUBTRACT THE HEIGHT OF THE ROAD FROM H
	var W := -get_gravity().y * get_gravity_scale() * mass
	var a := front_wheel_base
	var b := rear_wheel_base
	var t := track_front * 0.5 * W
	var Fx := longitudinal_force * h
	var Fy := lateral_force * h
	
	var Wfr := 0.5 * (Fx - b * W) * (-1.0 + Fy / t) / (a + b)
	var Wbr := 0.5 * (Fx + a * W) * ( 1.0 - Fy / t) / (a + b)
	var Wbl := 0.5 * (Fx + a * W) * ( 1.0 + Fy / t) / (a + b)
	var Wfl := 0.5 * (Fx - b * W) * (-1.0 - Fy / t) / (a + b)
