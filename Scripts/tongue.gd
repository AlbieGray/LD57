extends CharacterBody2D

@export var speed = 20
@export var player: CharacterBody2D
@onready var nav_agent = $navAgent
@export var pin: PinJoint2D
@onready var timer = $Timer

var retreat
var ants
var initial_pos
var has_ant

func _ready():
	retreat = false
	has_ant = false
	initial_pos = global_position
	
#moves the tongue (nav agent)
func _physics_process(_delta: float) -> void:
	ants = get_tree().get_nodes_in_group("Ants")
	if(nav_agent.is_navigation_finished()):
		retreat = !retreat
		if(has_ant):
			get_node("Sprite2D").queue_free()
			has_ant = false
	makepath()
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

#function to set target position of tongue
#TODO: constant update of target rooms and randomly choose one
func makepath() -> void:
	if(!retreat):
		if(ants.size() != 0):
			nav_agent.target_position = ants.pick_random().global_position
		else:
			nav_agent.target_position = initial_pos
	elif(retreat):
		nav_agent.target_position = initial_pos


#if tongue touches the 
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Ants")):
		body.queue_free()
		var sprite = body.get_node("Sprite2D").duplicate()
		add_child(sprite)
		has_ant = true
		print("Touch ant")
		retreat = true
		timer.stop()
		
	pass
