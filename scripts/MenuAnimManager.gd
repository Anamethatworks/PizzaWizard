extends AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		play("MainMenuAnim")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "MainMenuAnim":
		current_animation = "MainMenuIdle"
