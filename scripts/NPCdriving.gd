extends CharacterBody3D

var accel = 2
var moveSpeed = 10
var Blocked = false
var timer = 0
var lastPosition = 0



@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var targets = get_tree().get_nodes_in_group("Targets")
var currentTarget

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTarget = targets[randi()%targets.size()]
	lastPosition = self.position
	
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if (timer >= 3):
		if (self.position.distance_to(lastPosition) <= 10):
			currentTarget = targets[randi()%targets.size()]
		timer = 0
		lastPosition = self.position
	
	
	if (Blocked == false):
		var direction = Vector3()
		
		#print(currentTarget.position.distance_to(self.position))
		
		if (currentTarget.position.distance_to(self.position) <= 25):
			#print("Current Location", currentTarget.position)
			currentTarget = targets[randi()%targets.size()]
			#print("New Location", currentTarget.position)
			#print("changed target")
	
		nav.target_position = currentTarget.global_position # this one needs the @onready vars we defined earlier
	
		direction = nav.get_next_path_position() - global_position # and so does this
		direction = direction.normalized()
	
		self.velocity = self.velocity.lerp(direction * moveSpeed, accel * delta)
	
		move_and_slide()
		


func _on_character_body_3d_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Blocked = true
		
		
func _on_character_body_3d_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		Blocked = false
		
