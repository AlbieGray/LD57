extends CharacterBody2D

@export var speed = 20
@export var player: CharacterBody2D
@onready var nav_agent = $navAgent

var retreat
var initial_pos

func _ready():
	retreat = false
	initial_pos = global_position
	
#moves the tongue (nav agent)
func _physics_process(_delta: float) -> void:
	makepath()
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

#function to set target position of tongue
#TODO: constant update of target rooms and randomly choose one
func makepath() -> void:
	if(!retreat):
		nav_agent.target_position = player.global_position
	elif(retreat):
		nav_agent.target_position = initial_pos
	

func _on_timer_timeout():
	#TODO: increase timer as game progresses
	retreat = !retreat

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Ants")):
		print("Touch ant")
	pass
