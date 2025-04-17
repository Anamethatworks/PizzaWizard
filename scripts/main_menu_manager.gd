extends Node3D

@onready var game_scene = preload("res://scenes/Neocrystalis.tscn")
@onready var menu_elements = preload("res://scenes/UI/menu_elements.tscn")
@onready var black_fade = $"BlackFade"
var start_button
var quit_button

var desired_start_mod = Color(1, 1, 1, 1)
var desired_quit_mod = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_menu_elements()
	await get_tree().process_frame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if desired_start_mod != start_button.modulate:
		start_button.modulate = lerp(start_button.modulate, desired_start_mod, 0.1 * delta * 100)
	if desired_quit_mod != quit_button.modulate:
		quit_button.modulate = lerp(quit_button.modulate, desired_quit_mod, 0.1 * delta * 100)


func _on_start_game_pressed() -> void:
	black_fade.call("MenuFadeIn", (self))
	Music.stop_menu_playback()
	start_button.visible = false
	quit_button.visible = false

func populate_menu_elements() -> void:
	var elements = menu_elements.instantiate()
	get_tree().root.get_child(0).add_child(elements)
	start_button = $"MenuElements/StartGame"
	quit_button = $"MenuElements/QuitGame"
	start_button.mouse_entered.connect(_on_start_game_mouse_entered)
	start_button.mouse_exited.connect(_on_start_game_mouse_exited)
	start_button.button_down.connect(_on_start_game_button_down)
	start_button.pressed.connect(_on_start_game_pressed)
	quit_button.mouse_entered.connect(_on_quit_game_mouse_entered)
	quit_button.mouse_exited.connect(_on_quit_game_mouse_exited)
	quit_button.button_down.connect(_on_quit_game_button_down)
	quit_button.pressed.connect(_on_quit_game_pressed)

func menu_fade_in_finished() -> void:
	var city_scene = game_scene.instantiate()
	DeliveryManager.clear_orders()
	get_tree().root.add_child(city_scene)
	black_fade.call("MenuFadeOut")
	get_tree().root.get_child(0).remove_child(get_tree().root.get_child(0).get_node("MenuElements"))
	Music.begin_gameplay_playback()

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_start_game_button_down() -> void:
	desired_start_mod = Color(0.3, 0.3, 0.3, 1)

func _on_start_game_mouse_exited() -> void:
	desired_start_mod = Color(1, 1, 1, 1)

func _on_start_game_mouse_entered() -> void:
	desired_start_mod = Color(0.6, 0.6, 0.6, 1)

func _on_quit_game_mouse_exited() -> void:
	desired_quit_mod = Color(1, 1, 1, 1)

func _on_quit_game_mouse_entered() -> void:
	desired_quit_mod = Color(0.6, 0.6, 0.6, 1)

func _on_quit_game_button_down() -> void:
	desired_quit_mod = Color(0.3, 0.3, 0.3, 1)
