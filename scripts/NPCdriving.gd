extends CharacterBody3D

var accel = 2
var moveSpeed = 10
var Blocked = false
var timer = 0
var lastPosition = 0
var ChekColl = 0



@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var targets = get_tree().get_nodes_in_group("Targets")
var currentTarget

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTarget = targets[randi()%targets.size()]
	lastPosition = self.position
	var driverType = randi()%3 + 1
	if (driverType == 1):
		accel = 3
		moveSpeed = 8
	if (driverType == 3):
		accel = 5
		moveSpeed = 15
	
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if (timer >= 3):
		if (self.position.distance_to(lastPosition) <= 10):
			currentTarget = targets[randi()%targets.size()]
		timer = 0
		lastPosition = self.position
		
		
	
	
	
	var direction = Vector3()
		
	if (currentTarget.position.distance_to(self.position) <= 25):
		currentTarget = targets[randi()%targets.size()]
	
	nav.target_position = currentTarget.global_position # this one needs the @onready vars we defined earlier
	
	direction = nav.get_next_path_position() - global_position # and so does this
	direction = direction.normalized()
	
	self.velocity = self.velocity.lerp(direction * moveSpeed, accel * delta)
	
	
	if (Blocked == false):
		rotation.y = atan2(self.velocity.x, self.velocity.z)
	if (Blocked == true):
		self.velocity = Vector3(0,0,0)
	
	move_and_slide()
	Blocked = false
	
	if get_slide_collision_count() > 0:
		var Coll = self.get_slide_collision((get_slide_collision_count() - 1))
		#sprint(Coll)
		#for j in range(0, Coll.get_collision_count()-1):
					#print("testing")
		if Coll != null:
			if Coll.get_collider(0).is_in_group("Player"):
				Blocked = true
				#print("working")
	
