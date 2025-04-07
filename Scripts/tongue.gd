extends CharacterBody2D

@export var speed = 20
@export var player: CharacterBody2D
@onready var nav_agent = $navAgent
@export var pin: PinJoint2D
@onready var timer = $Timer

var retreat
var rooms
var initial_pos

func _ready():
	retreat = false
	initial_pos = global_position
	
#moves the tongue (nav agent)
func _physics_process(_delta: float) -> void:
	rooms = get_tree().get_nodes_in_group("Rooms")
	if(nav_agent.is_navigation_finished()):
		timer.start()
		retreat = !retreat
	makepath()
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

#function to set target position of tongue
#TODO: constant update of target rooms and randomly choose one
func makepath() -> void:
	if(!retreat):
		if(rooms.size() != 0):
			nav_agent.target_position = rooms.pick_random().global_position
	elif(retreat):
		nav_agent.target_position = initial_pos
	

func _on_timer_timeout():
	#TODO: increase timer as game progresses
	retreat = !retreat

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Ants")):
		print("Touch ant")
		retreat = true
		timer.stop()
		
	pass
