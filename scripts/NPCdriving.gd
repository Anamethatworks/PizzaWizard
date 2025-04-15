extends CharacterBody3D

var accel = 1
var moveSpeed = 3.5
var Blocked = false
var timer = 0
var lastPosition = 0
var ChekColl = 0
var ClosList = []
var LastDistance = Vector3(0,0,0)


@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var targets = get_tree().get_nodes_in_group("Targets")
@onready var Player = get_tree().get_nodes_in_group("Player")[0]
var currentTarget

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTarget = targets[randi()%targets.size()]
	lastPosition = self.position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var direction = Vector3()
	if (currentTarget.global_position.distance_to(self.global_position) <= 15):
		currentTarget = targets[randi()%targets.size()]
	
	nav.target_position = currentTarget.global_position # this one needs the @onready vars we defined earlier
	
	direction = nav.get_next_path_position() - global_position # and so does this
	
	self.velocity = self.velocity.lerp(direction * moveSpeed, accel * delta)
	
	if (Blocked == false):
		rotation.y = atan2(self.velocity.x, self.velocity.z)
	if (Blocked == true):
		self.velocity = Vector3(0,0,0)
	
	move_and_slide()
	Blocked = false
	if get_slide_collision_count() > 0:
		var Coll = self.get_slide_collision((get_slide_collision_count() - 1))
		if Coll != null:
			if Coll.get_collider(0).is_in_group("Player"):
				Blocked = true
	
func ClosestTargets():
	var fstClose = null
	var SndClose = null
	var TrdClose = null
	for i in targets:
		if fstClose == null:
			fstClose = i 
		else:
			if (Player.position.distance_to(i.position) < Player.position.distance_to(fstClose.position)):
				fstClose = i 
			else:
				if SndClose == null:
					SndClose = i
				else:
					if (Player.position.distance_to(i.position) < Player.position.distance_to(SndClose.position)):
						SndClose = i
					else:
						if TrdClose == null:
							TrdClose = i
						else:
							if (Player.position.distance_to(i.position) < Player.position.distance_to(TrdClose.position)):
								TrdClose = i
	ClosList = [fstClose, SndClose, TrdClose]
	
	
	
	
	
	
	
	
