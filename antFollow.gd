extends CharacterBody2D

@export var speed = 200
@onready var followPath = $"../followPath"
@onready var digPath = $"../Node2D/digPath"

var mouse_pos = null

func _physics_process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	if Input.is_action_pressed("leftMouse", true):
		var direction = (mouse_pos - position).normalized()
		velocity = direction*speed
	else: 
		velocity = Vector2(0,0)
	
		
