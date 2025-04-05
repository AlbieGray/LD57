extends Node2D



var mouse_pos = null

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("leftMouse"):
		if path.curve.get_baked_points().size() == 0 or mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos)) != 0:
			path.curve.add_point(mouse_pos)
			line.add_point(mouse_pos)
	else:
		line.clear_points()
		
	if Input.is_action_just_released("leftMouse"):
		follow.progress += delta*speed
		
