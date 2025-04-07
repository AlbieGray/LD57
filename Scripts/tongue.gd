extends CharacterBody2D

@export var speed = 20
@export var player: CharacterBody2D
@onready var nav_agent = $navAgent
	
#moves the tongue (nav agent)
func _physics_process(_delta: float) -> void:
	makepath()
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

#function to set target position of tongue
#TODO: constant update of target rooms and randomly choose one
func makepath() -> void:
	nav_agent.target_position = get_global_mouse_position()
	

func _on_timer_timeout():
	pass
