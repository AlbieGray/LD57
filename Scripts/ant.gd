extends CharacterBody2D

enum state{idle, following_path,}
var current_path_follow:PathFollow2D = null
var make_room_offset:Vector2 = Vector2(0, 0)

@export var speed = 200
@onready var followPath = $DigPath/digPath/followPath

var line = null
var tilemap = null
@onready var path = $DigPath/digPath
var current_path = path
@onready var follow = $DigPath/digPath/followPath

var room_path = preload("res://Scenes/room_path.tscn")

var mouse_pos = null
var drawing = false
var selected = true
var pathfinding = false



func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	# detect if clicked
	if Input.is_action_just_pressed("rightMouse"):
		if mouse_pos.distance_to(position) < 15:
			drawing = true
			print("started drawing")
	
	if Input.is_action_just_pressed("leftMouse"):
		if selected:
			selected = false
		elif mouse_pos.distance_to(position) < 15:
			selected = true
			print("just selected")
		else:
			selected = false
		$SelectedRing.visible = selected
	
	 # path following
	if current_path_follow != null:
		current_path_follow.progress += delta*speed
		position = current_path_follow.position
	
	if Input.is_action_just_pressed("make_room"):
		make_room()
	
	
	# making line and path
	mouse_pos = get_global_mouse_position()
	if drawing and Input.is_action_pressed("rightMouse"):
		if path.curve.get_baked_points().size() == 0 or mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos)) != 0:
			path.curve.add_point(mouse_pos)
			line.add_point(mouse_pos)
			current_path_follow = $DigPath/digPath/followPath
			current_path_follow.loop = false
			current_path_follow.position = position
	
	elif drawing and Input.is_action_just_released("rightMouse"):
		drawing = false
		print("ending drawing")
		line.clear_points()
		
	
	elif selected and not drawing and Input.is_action_just_released("rightMouse"):
		var tile_coords = tilemap.local_to_map(tilemap.to_local(mouse_pos))
		var tile_atlas_coords:Vector2 = tilemap.get_cell_atlas_coords(tile_coords)
		if tile_atlas_coords == Vector2(0, 0):
			pass
		elif tile_atlas_coords == Vector2(1, 0):
			current_path_follow = null
			path.curve.clear_points()
			line.clear_points()
			
			print("pathfinding to "+str(tile_coords))
			$NavigationAgent2D.target_position = mouse_pos
			pathfinding = true
	
	if pathfinding:
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()

		# Calculate the new velocity
		var new_velocity = current_agent_position.direction_to(next_path_position) * speed * 2
		set_velocity(new_velocity)
		
		if $NavigationAgent2D.is_navigation_finished():
			print("finished navigating")
			pathfinding = false
			velocity = Vector2(0,0)
	
	move_and_slide()


func make_room() -> void:
	current_path = room_path.instantiate()
	add_child(current_path)
	
	current_path_follow = current_path.get_node("PathFollow2D")
	current_path_follow.loop = false
	make_room_offset = current_path_follow.position-position
	
	for i in range(current_path.curve.point_count):
		current_path.curve.set_point_position(i, current_path.curve.get_point_position(i)-make_room_offset)
	

func _on_area_2d_body_shape_entered(body_rid: RID, body, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer and not pathfinding:
		var coords = body.get_coords_for_body_rid(body_rid)
		body.set_cell(coords, body.tile_set.get_source_id(0), Vector2(1, 0))
