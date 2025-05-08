#Adapted from upgrade_station from Sophie
class_name RefuelStation extends Area3D
## Class for a refuel station.
## NOTE: Refuel stations need a CollisionShape3D added as a child to work
## 		This is done so the collision area can be modified for each station

var player_present = false

func _ready() -> void:
	$Container.update_info()
   
func _process(_delta) -> void:
	if player_present:
		if Input.is_action_just_pressed("Refuel"):
			var cost = ceil((Magic.max_mana - Magic.mana) / 10.0)
			if Money.player_gold >= cost:
				Money.earn_money(-cost)
				Magic.add_mana(Magic.max_mana - Magic.mana)

func _on_body_entered(body: Node3D) -> void:
	# Determine if the body is the player
	if body.name == "Player":
		player_present = true

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_present = false
