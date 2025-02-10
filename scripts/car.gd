extends VehicleBody3D

const ENGINE_FORCE: float = 6000.0
const BRAKE_FORCE: float = 4400.0
const MAX_STEERING_ANGLE: float = TAU / 16.0
const THROTTLE_SPEED: float = 100000.0
const STEERING_SPEED: float = 10.0


func _physics_process(delta: float) -> void:
	
	## The minimum longitudinal velocity for the car controller
	## To begin accelerating in the opposite direction instead of braking
	const MIN_BRAKE_VELOCITY: float = 100.0
	
	var longitudinal_velocity := -cos(rotation.y) * linear_velocity.z - sin(rotation.y) * linear_velocity.x
	print(get_engine_force())
	
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
	
	
	
	
