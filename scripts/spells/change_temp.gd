extends Spell
class_name ChangeTempSpell

# Whether the spell increases or decreases the temperature of a pizza
# true = increases, false = decreases
var delta_temp_pos : bool

func _init(power : float, incinerate : bool) -> void:
	var pow : float = power
	var name : String
	var desc : String
	delta_temp_pos = incinerate
	if incinerate:
		name = "Incinerate"
		desc = "Heats up all the pizzas in your car."
	else:
		name = "Refrigerate"
		desc = "Cools down all the pizzas in your car."
	var cost : int = int(power * 0.6)
	super._init(cost, pow, name, desc)
	
func is_valid_casting(caster : Node3D) -> bool:
	var mana_valid = super.is_valid_casting(caster)
	var pizzas_to_heat = len(DeliveryManager.current_orders) > 0
	return mana_valid and pizzas_to_heat

func cast(caster : Node3D) -> void:
	super.cast(caster)
	var delta_temp
	if delta_temp_pos:
		delta_temp = power * 0.5
	else:
		delta_temp = -power * 0.5
	for order in DeliveryManager.current_orders:
			order.ordered_pizza.temperature += delta_temp 
