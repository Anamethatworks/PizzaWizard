extends Node

@onready var black_fade_panel = $"BlackPanel"
@onready var black_fade_anim = $"BlackFadeAnim"

var main_menu_manager
var pause_menu_manager

#0 = main menu, 1 = game
var state = 0

func MenuFadeIn(menu_manager) -> void:
	if !main_menu_manager:
		main_menu_manager = menu_manager
	black_fade_anim.play("MenuFadeIn")

func MenuFadeOut() -> void:
	black_fade_anim.play("MenuFadeOut")

func PauseFadeIn(pause_manager) -> void:
	if !pause_menu_manager:
		pause_menu_manager = pause_manager
	black_fade_anim.play("MenuFadeIn")

func PauseFadeOut() -> void:
	black_fade_anim.play("MenuFadeOut")

func _on_black_fade_anim_animation_finished(anim_name:StringName) -> void:
	if state == 0:
		if anim_name == "MenuFadeIn":
			print ("loading game")
			main_menu_manager.call("menu_fade_in_finished")
			state = 1

	elif state == 1:
		if anim_name == "MenuFadeIn":
			print ("loading menu")
			pause_menu_manager.call("pause_fade_in_finished")
			main_menu_manager.call("populate_menu_elements")
			state = 0
