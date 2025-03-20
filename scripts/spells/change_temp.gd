extends Spell
class_name ChangeTempSpell

# Whether the spell increases or decreases the temperature of a pizza
# true = increases, false = decreases
var delta_temp_pos : bool

func _init(delta_temp : float) -> void:
	var pow : float = abs(delta_temp)/2
	var name : String
	if delta_temp > 0:
		name = "Incinerate"
		delta_temp_pos = true
	else:
		name = "Refrigerate"
		delta_temp_pos = false
	var cost : float = power * 0.6
	super._init(cost, pow, name)
	
func is_valid_casting(caster : Node3D) -> bool:
	var mana_valid = super.is_valid_casting(caster)
	var pizzas_to_heat = len(DeliveryManager.current_orders) > 0
	return mana_valid and pizzas_to_heat

func cast(caster : Node3D) -> void:
	super.cast(caster)
	var delta_temp
	if delta_temp_pos:
		delta_temp = power * 2
	else:
		delta_temp = -power * 2
	for order in DeliveryManager.current_orders:
			order.ordered_pizza.temperature += delta_temp 
