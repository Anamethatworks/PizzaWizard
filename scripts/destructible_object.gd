extends RigidBody3D

var sleeping_state_changed_counter = 0
@onready var anim = $"DestructAnim"

func _on_sleeping_state_changed() -> void:
	if (sleeping_state_changed_counter == 1):
		anim.play("DestructFlash")
	sleeping_state_changed_counter += 1

	
func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
