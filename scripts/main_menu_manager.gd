extends Node3D

@onready var game_scene = preload("res://scenes/Neocrystalis.tscn")
@onready var menu_elements = preload("res://scenes/packed scenes/menu_elements.tscn")
@onready var black_fade_panel = $"BlackFade/BlackPanel"
@onready var black_fade_anim = $"BlackFade/BlackFadeAnim"
@onready var start_button = $"MenuElements/StartGame"
@onready var quit_button = $"MenuElements/QuitGame"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass #print (black_fade_anim.current_animation_position)


func _on_start_game_pressed() -> void:
	if !black_fade_anim.is_playing():
		black_fade_anim.play("MenuFadeIn")
		start_button.visible = false
		quit_button.visible = false


func _on_black_fade_anim_animation_finished(anim_name:StringName) -> void:
	if anim_name == "MenuFadeIn":
		var city_scene = game_scene.instantiate()
		get_tree().root.add_child(city_scene)
		black_fade_anim.play("MenuFadeOut")
		print (get_tree().root.get_child(0))
		get_tree().root.get_child(0).remove_child(get_tree().root.get_child(0).get_child(1))


func _on_quit_game_pressed() -> void:
	get_tree().quit()
