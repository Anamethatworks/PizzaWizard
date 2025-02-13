extends CharacterBody3D

var MaxSpeed = 20.0
var Speed = 10
const JUMP_VELOCITY = 4.5
var direction = Vector3(0,0,0)
var forward = 0



func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#if Input.is_action_pressed("MoveForward") or Input.is_action_pressed("MoveBackward"):
	var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	#if Input.is_action_pressed("MoveForward") or Input.is_action_pressed("MoveBackward"):
		#direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("MoveForward"):
		forward -= 1*delta
	if Input.is_action_pressed("MoveBackward"):
		forward += 1*delta
		
	if not Input.is_action_pressed("MoveForward") and not Input.is_action_pressed("MoveBackward"):
		Speed = Speed * (1-(delta/2))
		forward = forward * (1-delta)
	
	direction = transform.basis.z * forward
	#print(direction)
			
	if Input.is_action_pressed("MoveForward"):
		if Speed <= 1:
			Speed = 1
		Speed = Speed * (1+(delta*2))
		if Speed > MaxSpeed:
			Speed = MaxSpeed	
	if Input.is_action_pressed("MoveBackward"):
		if Speed <= 1:
			Speed = 1
		Speed = Speed * (1 + delta)
		if Speed > MaxSpeed:
			Speed = MaxSpeed
			
	#if not Input.is_action_pressed("MoveForward") and not Input.is_action_pressed("MoveBackward"):
		#Speed = Speed * (1-(delta/2))
		#velocity.x = velocity.x * (1-delta) 
		#velocity.z = velocity.z * (1-delta)
		
	if Input.is_action_pressed("MoveRight"):
		rotation -= Vector3 (0, input_dir.x * delta*2, 0)
	if Input.is_action_pressed("MoveLeft"):
		rotation -= Vector3 (0, input_dir.x * delta*2, 0)
	
	velocity.x = direction.x * Speed #* sin(rotation.x)
	velocity.z = direction.z * Speed #* cos(rotation.x)
	
	if velocity.x > 15:
		velocity.x = 15
	if velocity.x < -15:
		velocity.x = -15
	
	if velocity.z > 15:
		velocity.z = 15
	if velocity.z < -15:
		velocity.z = -15
		
	
	
	

	move_and_slide()
	
