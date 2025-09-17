extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		$AnimationPlayer.play("Collected")
		body.coins_collected += 1
		get_parent().get_node("UI/Control").update_coins_text(body.coins_collected)
		$CoinCollected.play()

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
