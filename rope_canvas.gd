extends Node2D

var Rope = preload("res://Scenes/rope/rope.tscn")
var start := Vector2.ZERO
var end := Vector2.ZERO
var rope 
@onready var tip = $Tongue

func _ready():
	rope = Rope.instantiate()
	start = rope.get_child(0).global_position
	end = tip.global_position
	add_child(rope)
	rope.spawn_rope(start, end)
	
func _process(delta: float) -> void:
	var past = end
	end = tip.global_position
	if end != Vector2.ZERO and end != past:
		rope.extend_rope(end)
		rope.shrink_rope(end)

func _input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if start == Vector2.ZERO:
			start = get_global_mouse_position()
