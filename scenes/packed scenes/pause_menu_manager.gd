extends Control

@onready var fade_mask = $"FadeMask"
@onready var mask_anim = $"PauseMenuAnim"
@onready var paused_text = $"FadeMask/PausedText"
@onready var continue_text = $"FadeMask/ContinueGame/RichTextLabel"
@onready var menu_text = $"FadeMask/BackToMenu/RichTextLabel"
@onready var quit_text = $"FadeMask/QuitGame/RichTextLabel"
@onready var cont_button = $"FadeMask/ContinueGame"
@onready var menu_button = $"FadeMask/BackToMenu"
@onready var quit_button = $"FadeMask/QuitGame"


var paused_text_freq = 2.0

var hover_bonus = 1.5
var continue_curr_bonus = 1.0
var menu_curr_bonus = 1.0
var quit_curr_bonus = 1.0

var cont_hovered = false
var menu_hovered = false
var quit_hovered = false
var pause_active = false

var desired_cont_mod = Color(1, 1, 1, 1)
var desired_menu_mod = Color(1, 1, 1, 1)
var desired_quit_mod = Color(1, 1, 1, 1)

var pause_lerp = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("Pause"):
		if !pause_active:
			mask_anim.play("FadeInPauseMenu")
			get_tree().paused = true
		else:
			mask_anim.play("FadeOutPauseMenu")
			get_tree().paused = false
		pause_active = !pause_active

	if pause_active:
		if desired_cont_mod != cont_button.modulate:
			cont_button.modulate = lerp(cont_button.modulate, desired_cont_mod, 0.1)
		if desired_menu_mod != cont_button.modulate:
			menu_button.modulate = lerp(menu_button.modulate, desired_menu_mod, 0.1)
		if desired_quit_mod != quit_button.modulate:
			quit_button.modulate = lerp(quit_button.modulate, desired_quit_mod, 0.1)

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_back_to_menu_pressed() -> void:
	pass # Replace with function body.

func _on_continue_game_pressed() -> void:
	pause_active = false
	get_tree().paused = false
	mask_anim.play("FadeOutPauseMenu")

func _on_back_to_menu_mouse_exited() -> void:
	menu_hovered = false
	desired_menu_mod = Color(1, 1, 1, 1)

func _on_back_to_menu_mouse_entered() -> void:
	menu_hovered = true
	desired_menu_mod = Color(0.4, 0.4, 0.4, 1)

func _on_quit_game_mouse_exited() -> void:
	quit_hovered = false
	desired_quit_mod = Color(1, 1, 1, 1)

func _on_quit_game_mouse_entered() -> void:
	quit_hovered = true
	desired_quit_mod = Color(0.4, 0.4, 0.4, 1)

func _on_continue_game_mouse_exited() -> void:
	cont_hovered = false
	desired_cont_mod = Color(1, 1, 1, 1)

func _on_continue_game_mouse_entered() -> void:
	cont_hovered = true
	desired_cont_mod = Color(0.4, 0.4, 0.4, 1)
