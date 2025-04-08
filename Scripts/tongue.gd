extends CharacterBody2D

var base_speed = 0
@export var speed = 0
@export var player: CharacterBody2D
@onready var nav_agent = $navAgent
@export var pin: PinJoint2D
@onready var timer = $Timer
@onready var game = get_parent()

var retreat
var ants
var initial_pos
var has_ant
var distracted
var target_ant

func _ready():
	retreat = false
	has_ant = false
	distracted = false
	initial_pos = global_position
	target_ant = -1
	ants = get_tree().get_nodes_in_group("Ants")
	nav_agent.target_position = initial_pos
	makepath()
	
#moves the tongue (nav agent)
func _physics_process(_delta: float) -> void:
	print(base_speed)
	speed = global_position.y * 0.005 + base_speed
	ants = get_tree().get_nodes_in_group("Ants")
	if(nav_agent.is_navigation_finished()):
		if(retreat):
			get_parent().reset_rope()
		retreat = !retreat
		if(has_ant):
			get_node("AnimatedSprite2D").queue_free()
			has_ant = false
	if(distracted):
		nav_agent.target_position = ants[target_ant].global_position
		distracted = !distracted
		if(has_ant):
			#TODO: release ant
			var new_ant = ants.pick_random().duplicate()
			new_ant.position = global_position
			new_ant.sprite = get_node("AnimatedSprite2D")
			get_node("AnimatedSprite2D").queue_free()
			has_ant = false
	else:
		makepath()
		if(target_ant != -1):
			nav_agent.target_position = ants[target_ant].global_position
		else:
			nav_agent.target_position = initial_pos
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	$tongueSprite.rotation = dir.angle() - PI/2
	velocity = dir * speed
	move_and_slide()

#function to set target position of tongue
#TODO: constant update of target rooms and randomly choose one
func makepath() -> void:
	if(!retreat):
		if(ants.size() != 0 and target_ant == -1):
			target_ant = randi_range(0, ants.size()-1)
		elif(ants.size() == 0):
			target_ant = -1
	elif(retreat):
		target_ant = -1


#if tongue touches the ant
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Ants")):
		game.kill_ant(body)
		var sprite = body.get_node("AnimatedSprite2D").duplicate()
		add_child(sprite)
		has_ant = true
		print("Touch ant")
		retreat = true
		timer.stop()
		
#TODO: change ant to grab index of ant
func got_distracted(ant):
	distracted = !distracted
	target_ant = ant


func _on_start_timer_timeout() -> void:
	base_speed = 20
	speed = 20
