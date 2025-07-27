extends CharacterBody2D

var dragging = false

func _process(delta) -> void:
	if dragging:
		var target_pos = get_global_mouse_position()
		var motion = target_pos - global_position
		if motion.length() > 0:
			var collision = move_and_collide(motion)
			if collision:
				dragging = false

func _on_area_2d_input_event(viewport: Node, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and $"../Companion".texture.resource_path == "res://sprites/spr_greyp.png":
		dragging = not dragging

func _on_area_2d_area_entered(area) -> void:
	if dragging:
		if "color" not in area.name:
			dragging = false
