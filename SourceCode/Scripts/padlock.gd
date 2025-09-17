extends Area2D

func change_to_level_completed_scene():
	get_tree().change_scene_to_file("res://Scenes/level_completed.tscn")	

func _on_body_entered(body):
	if body.is_in_group("Player") and body.key_collected:
		call_deferred("change_to_level_completed_scene") 
