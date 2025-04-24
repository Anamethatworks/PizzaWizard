extends CharacterBody3D

var accel: float = 10.0
var moveSpeed: float = 10.0
var Stuntimer: float = 0.0
var ClosList: Array[Marker3D] = []
var AiOn := true
var DriverStun := false
var KillTimer: float = 0

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var targets: Array[Node] = get_tree().get_nodes_in_group("Targets")
@onready var player: Player = get_tree().get_nodes_in_group("Player")[0]
var currentTarget: Marker3D

var delta2: float = 0.0


var current_link: NavigationLink3D = null

static var first: bool = true
var is_first: bool = false

var stuck: bool = false
var stuck_frame_counter: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTarget = targets.pick_random()
	self.get_child(1).get_child(0).visible = true
	if first:
		nav.debug_enabled = true
		first = false
		is_first = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta2 = delta
	#self.visb

	if nav.is_navigation_finished():
		ClosestTargets()
		currentTarget = ClosList.pick_random()
	
	nav.target_position = currentTarget.global_position
	
	var direction = Vector3()
	if is_instance_valid(current_link):
		#print("AT: " + str(global_position))
		#print("TO: " + str(nav.get_next_path_position()))
		direction = current_link.get_global_end_position() - global_position
		var endpos: Vector3 = current_link.get_global_end_position()
		var d = Vector2(global_position.x, global_position.z).distance_squared_to(Vector2(endpos.x, endpos.z))
		if d < 0.25 or d > 1.0:
			current_link = null
			direction = nav.get_next_path_position() - global_position
			#if is_first: print("LINK FINISHED")
	else:
		direction = nav.get_next_path_position() - global_position
	
	direction.y = 0.0
	
	nav.velocity = nav.velocity.move_toward(direction.normalized() * moveSpeed, accel * delta)
	
	if DriverStun == false:
		rotation.y = atan2(self.velocity.x, self.velocity.z)
	
	if DriverStun == true:
		nav.velocity = Vector3(0,0,0)
		Stuntimer += delta
		if Stuntimer >= 3:
			DriverStun = false
			Stuntimer = 0
	
	
	if AiOn == true:
		move_and_slide()
		if get_slide_collision_count() > 0:
			var Coll = self.get_slide_collision((get_slide_collision_count() - 1))
			if Coll != null:
				if Coll.get_collider(0).is_in_group("Player"):
					#DeathCycle()
					self.velocity = Coll.get_collider_velocity()    #get_collider(0).GetNormal()
					self.velocity *= 2
					self.velocity.rotated(Vector3(0,1,0), deg_to_rad(randi_range(-20, 20)))
					move_and_slide()
					DriverStun = true
		
				
	
func ClosestTargets():
	var fstClose: Marker3D = null
	var SndClose: Marker3D = null
	var TrdClose: Marker3D = null
	for i: Marker3D in targets:
		if not is_instance_valid(fstClose):
			fstClose = i 
		else:
			if player.position.distance_to(i.position) < player.position.distance_to(fstClose.position):
				fstClose = i 
			else:
				if not is_instance_valid(SndClose):
					SndClose = i
				else:
					if player.position.distance_to(i.position) < player.position.distance_to(SndClose.position):
						SndClose = i
					else:
						if not is_instance_valid(TrdClose):
							TrdClose = i
						else:
							if player.position.distance_to(i.position) < player.position.distance_to(TrdClose.position):
								TrdClose = i
	ClosList = [fstClose, SndClose, TrdClose]
	
	
func DeathCycle():
	Stuntimer = -10
	$AnimationPlayer.play("DriverDeath")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	%"../..".queue_free() # Replace with function body.


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if velocity.is_zero_approx():
		stuck_frame_counter += 1
		stuck = (stuck_frame_counter > 10)
	elif stuck_frame_counter > 0:
		stuck_frame_counter -= 1
		stuck = (stuck_frame_counter > 0)
	if DriverStun:
		self.velocity = self.velocity.move_toward(Vector3.ZERO, accel * delta2)
	elif stuck or is_instance_valid(current_link):
		self.velocity = self.velocity.move_toward(nav.velocity, accel * delta2)
	else:
		self.velocity = self.velocity.move_toward(safe_velocity, accel * delta2)
	move_and_slide()
	nav.velocity = self.velocity
	
	$"../..".global_position = self.global_position
	self.position = Vector3.ZERO
	keep_at_ground_height()


func _on_navigation_agent_3d_link_reached(details: Dictionary) -> void:
	#if is_first: print("REACHED LINK")
	if not is_instance_valid(current_link):
		#if is_first: print("SET CURRENT LINK")
		current_link = details.owner

func keep_at_ground_height() -> void:
	global_position.y = 0.0
