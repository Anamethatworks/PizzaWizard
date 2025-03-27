extends AnimationPlayer

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "StarBurstIntros":
		current_animation = "StarBurstIdles"
