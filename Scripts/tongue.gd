extends CharacterBody2D

@export var speed = 200
@export var player: CharacterBody2D
@onready var nav_agent = $navAgent
	
func _physics_process(delta: float) -> void:
	makepath()
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func _on_timer_timeout():
	pass
