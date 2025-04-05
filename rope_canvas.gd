extends Node2D

var Rope = preload("res://Scenes/rope/rope.tscn")
var start := Vector2.ZERO
var end := Vector2.ZERO

func _process(delta: float) -> void:
	var past = end
	if Input.is_action_pressed("leftMouse"):
		end = get_global_mouse_position()
		if end != Vector2.ZERO and end != past:
			for n in get_children():
				if !is_instance_of(n, StaticBody2D):
					remove_child(n)
			var rope = Rope.instantiate()
			add_child(rope)
			rope.spawn_rope(start, end)

func _input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if start == Vector2.ZERO:
			start = get_global_mouse_position()
