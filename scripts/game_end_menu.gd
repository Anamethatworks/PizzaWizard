extends CenterContainer

@onready var black_fade: Node = $"../../MainMenu/BlackFade"

@onready var moneyLabel: RichTextLabel = $"VBoxContainer/Score"
@onready var toMenuLabel: RichTextLabel = $"VBoxContainer/ToMenu"
@onready var quitLabel: RichTextLabel = $"VBoxContainer/Quit"
@onready var toMenuButton: Button = $"VBoxContainer/ToMenu/BackToMenu"
@onready var quitButton: Button = $"VBoxContainer/Quit/QuitGame"

var to_menu_button_hovered: bool = false
var quit_button_hovered: bool = false

func _ready() -> void:
	var score_text: String = ""
	if Money.player_gold == 0:
		score_text = "YOU DIDN'T EARN ANY MONEY TODAY"
	else:
		score_text = "YOU EARNED ${money} TODAY".replace("{money}", str(Money.player_gold))
		
	moneyLabel.set_text(moneyLabel.get_text().replace("{text}", score_text))

func _process(delta: float) -> void:
	# Process modulates for buttons that are hovered over or focused
	const LERP_POWER: float = 0.00179701029991 # = (0.9)^60
	if to_menu_button_hovered:
		var v: float = lerpf(toMenuLabel.modulate.r, 0.4, 1.0 - pow(LERP_POWER, delta))
		toMenuLabel.modulate = Color(v, v, v, 1.0)
	else:
		var v: float = lerpf(toMenuLabel.modulate.r, 1.0, 1.0 - pow(LERP_POWER, delta))
		toMenuLabel.modulate = Color(v, v, v, 1.0)
	if quit_button_hovered:
		var v: float = lerpf(quitLabel.modulate.r, 0.4, 1.0 - pow(LERP_POWER, delta))
		quitLabel.modulate = Color(v, v, v, 1.0)
	else:
		var v: float = lerpf(quitLabel.modulate.r, 1.0, 1.0 - pow(LERP_POWER, delta))
		quitLabel.modulate = Color(v, v, v, 1.0)

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_back_to_menu_pressed() -> void:
	TimeManager.reset_game()
	black_fade.call("PauseFadeIn", $"../PauseMenu")
	toMenuButton.disabled = true
	quitButton.disabled = true

## Sets the button with the name [param button]'s hovered state to [param state]
func _button_set_hover(button: StringName, state: bool) -> void:
	match button:
		&"TO MENU":
			to_menu_button_hovered = state
		&"QUIT":
			quit_button_hovered = state
		_: # Default
			push_warning("No button named " + button + " in game end menu")
