extends CharacterBody2D

enum state{idle, following_path,}
var current_path_follow:PathFollow2D = null
var make_room_offset:Vector2 = Vector2(0, 0)

@export var speed = 200
@onready var followPath = $DigPath/digPath/followPath

var line = null
@onready var path = $DigPath/digPath
@onready var follow = $DigPath/digPath/followPath

var room_path = preload("res://Scenes/room_path.tscn")

var mouse_pos = null
var drawing = false


func _ready() -> void:
	set_velocity(Vector2(0, 0))

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	 # path following
	if current_path_follow != null:
		current_path_follow.progress += delta*speed
		position = current_path_follow.position
	if Input.is_action_just_pressed("make_room"):
		make_room()
	
	if Input.is_action_just_pressed("leftMouse"):
		print(mouse_pos.distance_to(position))
		if mouse_pos.distance_to(position) < 15:
			drawing = true
	
	# making line and path
	mouse_pos = get_global_mouse_position()
	if drawing and Input.is_action_pressed("leftMouse"):
		if path.curve.get_baked_points().size() == 0 or mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos)) != 0:
			path.curve.add_point(mouse_pos)
			line.add_point(mouse_pos)
	elif Input.is_action_just_released("leftMouse"):
		drawing = false
		line.clear_points()
		current_path_follow = $DigPath/digPath/followPath
		current_path_follow.loop = false
		
		
	if Input.is_action_just_released("leftMouse"):
		follow.progress += delta*speed
		


func make_room() -> void:
	var room_path_node = room_path.instantiate()
	add_child(room_path_node)
	
	current_path_follow = room_path_node.get_node("PathFollow2D")
	current_path_follow.loop = false
	make_room_offset = current_path_follow.position-position
	
	for i in range(room_path_node.curve.point_count):
		room_path_node.curve.set_point_position(i, room_path_node.curve.get_point_position(i)-make_room_offset)
	print(make_room_offset)

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	var coords = body.get_coords_for_body_rid(body_rid)
	body.set_cell(coords, body.tile_set.get_source_id(0), Vector2(1, 0))
