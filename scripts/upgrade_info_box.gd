extends PanelContainer

@onready var station: Area3D = get_parent()

var stat: UpgradeableStat:
	get: return station.paired_upgrade

func _process(delta: float) -> void:
	# Move the panel to where the station is in the world
	self.set_position(get_viewport().get_camera_3d().unproject_position(station.global_position) - self.size * 0.5)
	
## Updates the text on the panel
func update_info() -> void:
	if stat.is_at_max_tier():
		set_texts(	"Upgrade Station: Max Level",
					"",
					"",
					"")
	elif stat.can_afford_upgrade():
		set_texts(	"Upgrade Station: %NAME%",
					"%DESC%",
					"Cost: %COST%G",
					"Enter station to purchase")
	else:
		set_texts(	"Upgrade Station: %NAME%",
					"%DESC%",
					"Cost: %COST%G",
					"Can't afford")

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
