extends Control

@onready var black_fade = $"../../MainMenu/BlackFade"
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

	if Input.is_action_just_pressed("Pause") and not TimeManager.out_of_time:
		if !pause_active:
			mask_anim.play("FadeInPauseMenu")
			set_buttons_visible()
			get_tree().paused = true
			
		else:
			mask_anim.play("FadeOutPauseMenu")
			set_buttons_invisible()
			get_tree().paused = false
		pause_active = !pause_active

	if pause_active:
		if desired_cont_mod != cont_button.modulate:
			cont_button.modulate = lerp(cont_button.modulate, desired_cont_mod, 0.1)
		if desired_menu_mod != cont_button.modulate:
			menu_button.modulate = lerp(menu_button.modulate, desired_menu_mod, 0.1)
		if desired_quit_mod != quit_button.modulate:
			quit_button.modulate = lerp(quit_button.modulate, desired_quit_mod, 0.1)

func pause_fade_in_finished() -> void:
	DeliveryManager.clear_orders()
	print (get_tree().root.get_child((1)))
	var ui_manager = $"../UIPanel/UIManager"
	ui_manager.call("clear_order_tickets")
	get_tree().root.get_child(1).queue_free()
	#get_tree().root.remove_child(get_tree().root.get_child((1)))
	black_fade.call("MenuFadeOut")

func set_buttons_visible() -> void:
	cont_button.set_visible(true)
	menu_button.set_visible(true)
	quit_button.set_visible(true)

func set_buttons_invisible() -> void:
	cont_button.set_visible(false)
	menu_button.set_visible(false)
	quit_button.set_visible(false)

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_back_to_menu_pressed() -> void:
	black_fade.call("PauseFadeIn", (self))

	get_tree().paused = false
	cont_button.visible = false
	menu_button.visible = false
	quit_button.visible = false

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
