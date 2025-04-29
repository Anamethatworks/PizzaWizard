extends CharacterBody3D

var accel: float = 10.0
var moveSpeed: float = 15.0
var Stuntimer: float = 0.0
var AiOn := true
var DriverStun := false
var KillTimer: float = 0

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var targets: Array[Node] = get_tree().get_nodes_in_group("Targets")
@onready var player: Player = get_tree().get_nodes_in_group("Player")[0]
var currentTarget: Marker3D

var delta2: float = 0.0


var current_link: NavigationLink3D = null

var stuck: bool = false
var stuck_frame_counter: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTarget = targets.pick_random()
	self.get_child(1).get_child(0).visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta2 = delta
	#self.visb

	if nav.is_navigation_finished():
		ClosestTargets()
		currentTarget = targets[randi_range(0, 5)]
	
	nav.target_position = currentTarget.global_position
	
	var direction = Vector3()
	if is_instance_valid(current_link):
		direction = current_link.get_global_end_position() - global_position
		var endpos: Vector3 = current_link.get_global_end_position()
		var d = Vector2(global_position.x, global_position.z).distance_squared_to(Vector2(endpos.x, endpos.z))
		if d < 0.25 or d > 1.0:
			current_link = null
			direction = nav.get_next_path_position() - global_position
	else:
		direction = nav.get_next_path_position() - global_position
	
	direction.y = 0.0
	
	nav.velocity = nav.velocity.move_toward(direction.normalized() * moveSpeed, accel * delta)
	
	if DriverStun == false:
		rotation.y = lerp_angle(rotation.y, atan2(self.velocity.x, self.velocity.z), 1.0 - pow(0.01, delta))
	
	if DriverStun == true:
		nav.velocity = Vector3(0,0,0)
		Stuntimer += delta
		if Stuntimer >= 3:
			DriverStun = false
			Stuntimer = 0
	
	
func ClosestTargets():
	targets.sort_custom(distance_sort)

func distance_sort(a: Marker3D, b: Marker3D) -> bool:
	if player.global_position.distance_squared_to(a.global_position) < player.global_position.distance_squared_to(b.global_position):
		return true
	return false

func DeathCycle():
	Stuntimer = -10
	$AnimationPlayer.play("DriverDeath")
	
func process_offscreen_cars() -> void:
	var d := player.global_position.distance_squared_to(global_position)
	if d >= 4000.0:
		var player_direction: Vector2 = Vector2(player.linear_velocity.x, player.linear_velocity.z)
		if player_direction.length_squared() < 0.1:
			return
		player_direction = Vector2.from_angle(player_direction.angle() + randfn(0.0, 1.0)) # Perturb angle randomly
		var player_goal: Vector2 = Vector2(player.global_position.x, player.global_position.z) + \
			player_direction * 57.0
		
		var target_pos: Vector3 = Vector3(player_goal.x, 0.0, player_goal.y)
		$"../..".global_position = target_pos
		ClosestTargets()
		currentTarget = targets[randi_range(0, 5)]
		move_and_slide()
		if player.global_position.distance_squared_to(nav.get_next_path_position()) < 3750.0:
			cull()
		else:
			$"../..".global_position = nav.get_next_path_position()
			

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	cull()

## Culls the car
func cull() -> void:
	if is_instance_valid($"../.."):
		NPC_Spawner.CurrentCars -= 1
		$"../..".queue_free()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if not AiOn:
		return
	if velocity.is_zero_approx():
		stuck_frame_counter += 1
		stuck = (stuck_frame_counter > 10)
	elif stuck_frame_counter > 0:
		stuck_frame_counter -= 1
		stuck = (stuck_frame_counter > 0)
	if DriverStun:
		self.velocity = self.velocity.move_toward(Vector3.ZERO, accel * delta2 * 5.0)
	elif stuck or is_instance_valid(current_link):
		self.velocity = self.velocity.move_toward(nav.velocity, accel * delta2)
	else:
		self.velocity = self.velocity.move_toward(safe_velocity, accel * delta2)
	process_offscreen_cars()
	move_and_slide()
	if get_slide_collision_count() > 0:
		var Coll = self.get_slide_collision((get_slide_collision_count() - 1))
		if Coll != null:
			if Coll.get_collider(0).is_in_group("Player"):
				#DeathCycle()
				self.velocity += Coll.get_collider_velocity()    #get_collider(0).GetNormal()
				DriverStun = true
	nav.velocity = self.velocity
	
	$"../..".global_position = self.global_position
	self.position = Vector3.ZERO
	keep_at_ground_height()


func _on_navigation_agent_3d_link_reached(details: Dictionary) -> void:
	if not is_instance_valid(current_link):
		current_link = details.owner

func keep_at_ground_height() -> void:
	global_position.y = 0.0
