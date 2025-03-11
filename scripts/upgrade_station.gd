class_name UpgradeStation extends Area3D
## Class for an upgrade station.
## NOTE: Upgrade stations need a CollisionShape2D added as a child to work
## 		This is done so the collision area can be modified for each station

var paired_upgrade: UpgradeableStat ## The stat this station upgrades

## A list of upgrades without a station.
static var unpaired_upgrades: Array[UpgradeableStat] = []


func _ready() -> void:
	if unpaired_upgrades.is_empty():
		push_warning("There are more upgrades stations than there are upgrades. Some stations will not have an upgrade assigned.")
		return
	paired_upgrade = unpaired_upgrades.pop_back()
	$Container.update_info()
	UpgradeInfoBox.processing_upgrade_info_boxes.append($Container)

func _on_body_entered(body: Node3D) -> void:
	# Determine if the body is the player
	if body.name == "Player" and paired_upgrade.can_afford_upgrade() and not $Container.on_cooldown:
		paired_upgrade.buy_upgrade()
		if paired_upgrade.is_at_max_tier():
			# Don't bother with the cooldown, the upgrade was just maxed
			if get_new_stat(): # Try loading a new upgradeablestat
				$Container.start_cooldown()
			else:
				UpgradeInfoBox.processing_upgrade_info_boxes.erase($Container)
			$Container.update_info()
		else:
			$Container.start_cooldown()

## Pairs this station to a different, unpaired upgrade stat.
## In case we want stations to load new upgrades after maxing one out or something
## Returns if it successfully loaded a new UpgradeableStat
func get_new_stat() -> bool:
	if unpaired_upgrades.is_empty():
		return false # No stats to use
	else:
		if paired_upgrade.is_at_max_tier():
			# The upgrade was maxed, so don't return it to unpaired_upgrades
			paired_upgrade = unpaired_upgrades.pop_back()
			$Container.update_info()
			UpgradeInfoBox.processing_upgrade_info_boxes.append($Container)
			return true
		else:
			# The upgrade wasn't at max, so return it to unpaired_upgrades
			var temp: UpgradeableStat = paired_upgrade
			paired_upgrade = unpaired_upgrades.pop_back()
			$Container.update_info()
			if not UpgradeInfoBox.processing_upgrade_info_boxes.has($Container):
				UpgradeInfoBox.processing_upgrade_info_boxes.append($Container)
			unpaired_upgrades.append(temp)
			unpaired_upgrades.shuffle()
			return true
