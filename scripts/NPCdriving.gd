extends CharacterBody3D

var accel = 1
var moveSpeed = 3.5
var Blocked = false
var Stuntimer = 0
var ChekColl = 0
var ClosList = []
var AiOn = true
var DriverStun = false
var KillTimer = 0

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var targets = get_tree().get_nodes_in_group("Targets")
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var currentTarget

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTarget = targets[randi()%targets.size()]
	self.get_child(1).get_child(0).visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#self.visb

	var direction = Vector3()
	if (currentTarget.global_position.distance_to(self.global_position) <= 15):
		currentTarget = targets[randi()%targets.size()]
	
	nav.target_position = currentTarget.global_position # this one needs the @onready vars we defined earlier
	
	direction = nav.get_next_path_position() - global_position # and so does this
	
	self.velocity = self.velocity.lerp(direction * moveSpeed, accel * delta)
	
	if DriverStun == false:
		rotation.y = atan2(self.velocity.x, self.velocity.z)
	
	if DriverStun == true:
		self.velocity = Vector3(0,0,0)
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
	var fstClose = null
	var SndClose = null
	var TrdClose = null
	for i in targets:
		if fstClose == null:
			fstClose = i 
		else:
			if (player.position.distance_to(i.position) < player.position.distance_to(fstClose.position)):
				fstClose = i 
			else:
				if SndClose == null:
					SndClose = i
				else:
					if (player.position.distance_to(i.position) < player.position.distance_to(SndClose.position)):
						SndClose = i
					else:
						if TrdClose == null:
							TrdClose = i
						else:
							if (player.position.distance_to(i.position) < player.position.distance_to(TrdClose.position)):
								TrdClose = i
	ClosList = [fstClose, SndClose, TrdClose]
	
	
func DeathCycle():
	#AiOn = false
	#print("test")
	Stuntimer = -10
	self.get_child(0).play("DriverDeath")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.queue_free() # Replace with function body.
