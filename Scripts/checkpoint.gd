extends Area2D

func _on_body_entered(body):
	if body is Player:
		body.current_checkpoint_pos = global_position
