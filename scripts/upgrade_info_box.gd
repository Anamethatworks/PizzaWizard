class_name UpgradeInfoBox extends PanelContainer

@onready var station: Area3D
var on_cooldown := false ## If the station is on cooldown

## An array of all info boxes waiting for the player to get enough money to buy the upgrade
static var processing_upgrade_info_boxes: Array[UpgradeInfoBox] = []

## The UpgradeableStat that this box's station is paired with
var stat: UpgradeableStat:
	get: return station.paired_upgrade


func _ready() -> void:
	## How many seconds before an upgrade station can be used again
	station = get_parent()
	const UPGRADE_COOLDOWN_TIME: float = 2.0
	$CooldownTimer.wait_time = UPGRADE_COOLDOWN_TIME


func _process(_delta: float) -> void:
	# Move the panel to where the station is in the world
	self.set_position(get_viewport().get_camera_3d().unproject_position(station.global_position) - self.size * 0.5)
	if on_cooldown:
		update_info()

## Updates the text on the panel
func update_info() -> void:
	if on_cooldown: # Another upgrade is available, but the station is on cooldown
		set_texts(	"Upgrade Station",
					"Upgrade bought",
					"",
					"Next tier available in " + str(snappedf($CooldownTimer.time_left, 0.1)) + " s")
	elif stat.is_at_max_tier(): # Upgrade is at max tier, so no upgrade is available
		set_texts(	"Upgrade Station: Max Level",
					"",
					"",
					"")
	elif stat.can_afford_upgrade(): # The player can buy the upgrade
		set_texts(	"Upgrade Station: %NAME%",
					"%DESC%",
					"Cost: %COST%G",
					"Enter station to purchase")
	else: # Another upgrade is available, but the player cannot afford it
		set_texts(	"Upgrade Station: %NAME%",
					"%DESC%",
					"Cost: %COST%G",
					"Can't afford")

## Sets the text for each of the four text labels at once.
func set_texts(upgrade_name: String, description: String, cost: String, status: String) -> void:
	$VBoxContainer/UpgradeName.text = upgrade_name.replace("%NAME%", stat.get_upgrade_name()) if upgrade_name.contains("%NAME%") else upgrade_name
	$VBoxContainer/UpgradeDesc.text = description.replace("%DESC%", stat.get_description()) if description.contains("%DESC%") else description
	$VBoxContainer/UpgradeCost.text = cost.replace("%COST%", str(stat.get_cost())) if cost.contains("%COST%") else cost
	$VBoxContainer/UpgradeStatus.text = status
	# Make blank lines invisible
	$VBoxContainer/UpgradeName.set_visible(upgrade_name != "")
	$VBoxContainer/UpgradeDesc.set_visible( description != "")
	$VBoxContainer/UpgradeCost.set_visible(        cost != "")
	$VBoxContainer/UpgradeStatus.set_visible(    status != "")

## Updates all info boxes for upgrades the player can get depending on their
## money (i.e. not on cooldown or at max level)
## Call this whenever the player gains or spends money
## (This should only called when money is updated instead of every frame, for performance)
static func update_info_boxes() -> void:
	for box: UpgradeInfoBox in processing_upgrade_info_boxes:
		box.update_info()

## Starts the cooldown timer
func start_cooldown() -> void:
	processing_upgrade_info_boxes.erase(self)
	on_cooldown = true
	$CooldownTimer.start()

func _on_timer_timeout() -> void:
	on_cooldown = false
	update_info()
	processing_upgrade_info_boxes.append(self)
