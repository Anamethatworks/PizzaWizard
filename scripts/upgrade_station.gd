class_name UpgradeStation extends Area3D

## How many seconds before an upgrade station can be used again
const UPGRADE_COOLDOWN_TIME: float = 15.0

var paired_upgrade: UpgradeableStat
static var unpaired_upgrades: Array[UpgradeableStat] = []

var on_cooldown := false

func _ready() -> void:
	$CooldownTimer.wait_time = UPGRADE_COOLDOWN_TIME
	if unpaired_upgrades.is_empty():
		push_warning("There are more upgrades stations than there are upgrades. Some stations will not have an upgrade assigned.")
	paired_upgrade = unpaired_upgrades.pop_back()
	$Container.update_info()

func _process(delta: float) -> void:
	if on_cooldown:
		$Container.set_texts(	"Upgrade Station",
								"Upgrade bought",
								"",
								"Next tier available in " + \
								str(snappedf($CooldownTimer.time_left, 0.1)) + " s")

func _on_timer_timeout() -> void:
	on_cooldown = false
	$Container.update_info()


func _on_body_entered(body: Node3D) -> void:
	# Determine if the body is the player
	if body.name == "Player" and paired_upgrade.can_afford_upgrade() and not on_cooldown:
		paired_upgrade.buy_upgrade()
		if paired_upgrade.is_at_max_tier():
			# Don't bother with the cooldown, the upgrade was just maxed
			$Container.update_info()
		else:
			on_cooldown = true
			$CooldownTimer.start()
