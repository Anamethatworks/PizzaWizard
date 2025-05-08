class_name NPC_Spawner extends Node3D

var SpawnerList = []
var CloseList = []
const MaxCars: int = 15
static var CurrentCars: int = 0
var NumSpawners: int = 15
var DistanceChk = true
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var Driver = preload("res://scenes/packed scenes/Driver.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var i = 0
	while i < (NumSpawners-1): # Replace with function body.
		SpawnerList.append(get_child(i))
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#print(Player.position.distance_to(self.position))
	
	if CurrentCars < MaxCars:
		#DistanceChk = true
		#CloseList = CalcCloseList()
		var currentSpawner = SpawnerList.pick_random()
		#var ChildList = currentSpawner.get_children()
		#for j in ChildList:
			#if currentSpawner.global_position.distance_to(j.global_position) < 5 and j.is_in_group("VisChkr") == false:
				#pass
				#DistanceChk = false
		if player.global_position.distance_squared_to(currentSpawner.global_position) > 3000.0:
			var instance = Driver.instantiate()
			currentSpawner.add_child(instance)
			CurrentCars += 1
	else:
		MonitorDrivers()
	

func CalcCloseList():
	var fstClose = null
	var SndClose = null
	var TrdClose = null
	var i = 0
	while i < (NumSpawners-1):
		var ChildList = SpawnerList[i].get_children()
		var VisChk 
		for j in ChildList:
			#print(i, j)
			if j.is_in_group("VisChkr"):
				VisChk = j
		if fstClose == null:
			fstClose = SpawnerList[i] #Player.position.distance_to(SpawnerList[i].position)
		else:
			if (player.global_position.distance_to(SpawnerList[i].global_position) < player.global_position.distance_to(fstClose.global_position)) and VisChk.is_on_screen() == false:
				fstClose = SpawnerList[i] #Player.position.distance_to(SpawnerList[i].position)
			else:
				if SndClose == null:
					SndClose = SpawnerList[i]
				else:
					if (player.global_position.distance_to(SpawnerList[i].global_position) < player.global_position.distance_to(SndClose.global_position)) and VisChk.is_on_screen() == false:
						SndClose = SpawnerList[i]
					else:
						if TrdClose == null:
							TrdClose = SpawnerList[i]
						else:
							if (player.global_position.distance_to(SpawnerList[i].global_position) < player.global_position.distance_to(TrdClose.global_position)) and VisChk.is_on_screen() == false:
								TrdClose = SpawnerList[i]
		i += 1
							
							
					
					
	var TempList = [fstClose, SndClose, TrdClose]
	return TempList

func MonitorDrivers():
	var i = 0
	while i < (NumSpawners - 1):
		if (get_child(i).get_child(0) != null) and (get_child(i).get_child(0).is_in_group("VisChkr") == false) and CurrentCars >= 15:
			if Player.global_position.distance_to(get_child(i).get_child(0).global_position) > 135:
				get_child(i).get_child(0).queue_free()
				CurrentCars -= 1
				#print("working", Player.position.distance_to(get_child(i).get_child(0).global_position) )
		i += 1
		
	
