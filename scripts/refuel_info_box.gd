#Adapted from upgrade_info_box from Sophie
class_name RefuelInfoBox extends PanelContainer

@onready var station: CollisionShape3D
@onready var container: Container

## An array of all info boxes waiting for the player to get enough money to buy the upgrade
static var processing_refuel_info_boxes: Array[RefuelInfoBox] = []


func _ready() -> void:
	station = $"../Collider"
	container = $"."

func _process(_delta: float) -> void:
	# Move the panel to where the station is in the world
	self.set_position(get_viewport().get_camera_3d().unproject_position(station.global_position) - self.size * 0.5)
	if Magic.mana != Magic.max_mana:
		update_info()
	var windowSize = DisplayServer.window_get_size()
	var screenDiff = Vector2 (windowSize.x / 2 - (global_position.x + 100), windowSize.y / 2 - global_position.y)
	var desired_length = clamp(screenDiff.length() - 20, 0, 200)
	if (desired_length < 200):
		container.modulate = Color(1.0, 1.0, 1.0, lerp(0.0, 1.0, desired_length/200))

## Updates the text on the panel
func update_info() -> void:
	set_texts("Refuel Cost: [wave amp=25.0 freq=2.0 connected=1]%COST%[/wave]")

## Sets the text for each of the four text labels at once.
func set_texts(cost: String) -> void:
	$VBoxContainer/RefuelCost.text = cost.replace("%COST%", str(ceil((Magic.max_mana - Magic.mana) / 10.0))) if cost.contains("%COST%") else cost

## Updates all info boxes for upgrades the player can get depending on their
## money (i.e. not on cooldown or at max level)
## Call this whenever the player gains or spends money
## (This should only called when money is updated instead of every frame, for performance)
static func update_info_boxes() -> void:
	for box: RefuelInfoBox in processing_refuel_info_boxes:
		box.update_info()
