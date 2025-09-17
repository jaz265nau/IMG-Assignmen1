extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.key_collected = true
		$AnimationPlayer.play("Collected")
		$KeyCollected.play()

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
