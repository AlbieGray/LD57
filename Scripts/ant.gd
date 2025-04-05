extends CharacterBody2D

enum state{idle, following_path,}
var current_path_follow:PathFollow2D = null
var make_room_start_pos:Vector2 = Vector2(0, 0)

@export var speed = 200
@onready var followPath = $DigPath/digPath/followPath
@onready var digPath = $"../Node2D/digPath"

@onready var line = $DigPath/Line2D
@onready var path = $DigPath/digPath
@onready var follow = $DigPath/digPath/followPath
@onready var sprite = $DigPath/digPath/followPath/Ant/Sprite2D

var mouse_pos = null


func _ready() -> void:
	set_velocity(Vector2(0, 0))

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	if Input.is_action_pressed("leftMouse", true):
		var direction = (mouse_pos - position).normalized()
		velocity = direction*speed
	else: 
		velocity = Vector2(0,0)
	
	 # path following
	if current_path_follow != null:
		current_path_follow.progress += 1
		position = make_room_start_pos + current_path_follow.position
	if Input.is_action_pressed("make_room"):
		make_room()
	
	mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("leftMouse"):
		if path.curve.get_baked_points().size() == 0 or mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos)) != 0:
			path.curve.add_point(mouse_pos)
			line.add_point(mouse_pos)
	else:
		line.clear_points()
		current_path_follow = $DigPath/digPath/followPath
		
		
	if Input.is_action_just_released("leftMouse"):
		follow.progress += delta*speed
		


func make_room() -> void:
	current_path_follow = $RoomPath/PathFollow2D
	make_room_start_pos = current_path_follow.position-position

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	var coords = body.get_coords_for_body_rid(body_rid)
	body.set_cell(coords, body.tile_set.get_source_id(0), Vector2(1, 0))
