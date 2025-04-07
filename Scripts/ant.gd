extends CharacterBody2D

enum state{idle, following_path,}
var current_path_follow:PathFollow2D = null
var make_room_offset:Vector2 = Vector2(0, 0)

@export var speed = 200
@onready var followPath = $DigPath/digPath/followPath

var queen = false

var line_scene = preload("res://Scenes/line_drawer.tscn")
var line
var tilemap = null
@onready var path = $DigPath/digPath
var current_path = path
@onready var follow = $DigPath/digPath/followPath
@onready var game = get_parent()

var display_name = "unnamed"

var room_path = preload("res://Scenes/room_path.tscn")

var mouse_pos = null
var drawing = false
var selected = false
var pathfinding = false
var text_fading = false
var making_room = false
var digging = true
var mouse_hovered = false

const ant_names_script = preload("res://Scripts/ant_names.gd")

func _ready():
	#var line_draw = line_scene.instantiate()
	#add_child(line_draw)
	#line = line_draw.find_child("Line2D")
	
	var first_names = ant_names_script.new().first_names
	var second_names = ant_names_script.new().second_names
	display_name = first_names.pick_random() + " " + second_names.pick_random()
	$NameTag.text = display_name
	
	$Sprite2D.frame = randi_range(0, 4)

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	# detect if clicked
	if Input.is_action_just_pressed("rightMouse"):
		if selected and mouse_pos.distance_to(position) < 15:
			game.draw_line()
			path.curve.clear_points()
			drawing = true
	
	#if Input.is_action_just_pressed("leftMouse"):
		#if selected:
			#selected = false
		#elif mouse_pos.distance_to(position) < 15:
			#selected = true
			#get_parent().selected_ant = self
		#else:
			#selected = false
		#$SelectedRing.visible = selected
		#game.update_gui()
	
	 # path following
	if digging and current_path_follow != null:
		current_path_follow.progress += delta*speed
		position = current_path_follow.position
		$Sprite2D.rotation = current_path_follow.rotation + 90
		if current_path_follow.progress_ratio >= 1:
			digging = false
			path.curve.clear_points()
	
	if making_room:
		current_path_follow.progress += delta*speed
		position = current_path_follow.position
		$Sprite2D.rotation = current_path_follow.rotation + 90
		if current_path_follow.progress_ratio >= 1:
			making_room = false
	
	
	# making line and path
	mouse_pos = get_global_mouse_position()
	if drawing and Input.is_action_pressed("rightMouse"):
		if path.curve.get_baked_points().size() == 0 or mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos)) != 0:
			digging = true
			path.curve.add_point(mouse_pos)
			line.add_point(mouse_pos)
			current_path_follow = $DigPath/digPath/followPath
			current_path_follow.loop = false
			current_path_follow.position = position
	
	elif drawing and Input.is_action_just_released("rightMouse"):
		drawing = false
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
			
			$NavigationAgent2D.target_position = mouse_pos
			pathfinding = true
	
	if pathfinding:
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()

		# Calculate the new velocity
		var new_velocity = current_agent_position.direction_to(next_path_position) * speed * 2
		set_velocity(new_velocity)
		
		if $NavigationAgent2D.is_navigation_finished():
			pathfinding = false
			velocity = Vector2(0,0)
	
	
	if text_fading:
		$Speech.modulate = Color(255, 255, 255, 10*($VoicelineFadeout.time_left/$VoicelineFadeout.wait_time))
	
	move_and_slide()


func make_room() -> void:
	if game.stone < game.NEW_ROOM_COST:
		print("not enough stone!")
		return
	game.add_room()
	game.stone -= game.NEW_ROOM_COST
	game.update_gui()
	making_room = true
	current_path = room_path.instantiate()
	add_child(current_path)
	current_path_follow = current_path.find_child("RoomPathFollow")
	current_path_follow.loop = false
	current_path_follow.progress_ratio = 0
	make_room_offset = current_path_follow.position-position
	
	for i in range(current_path.curve.point_count):
		current_path.curve.set_point_position(i, current_path.curve.get_point_position(i)-make_room_offset)


func _on_area_2d_body_shape_entered(body_rid: RID, body, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer and not pathfinding:
		var coords = body.get_coords_for_body_rid(body_rid)
		var tile_type = tilemap.get_cell_atlas_coords(coords)
		body.set_cell(coords, body.tile_set.get_source_id(0), Vector2(1, 0))
		if tile_type == Vector2i(2, 0):
			game.stone += 1
			game.update_gui()
		if tile_type == Vector2i(3, 0):
			game.food += 1
			game.update_gui()


func set_speech(text, timeout=3) -> void:
	$Speech.modulate = Color(255, 255, 255, 255)
	$Speech.text = text
	$VoicelineFadeout.wait_time = timeout
	$VoicelineFadeout.start()
	text_fading = true

func _on_voiceline_timer_timeout() -> void:
	set_speech("stuff", 3)


func _on_voiceline_fadeout_timeout() -> void:
	text_fading = false



func _on_mouse_entered() -> void:
	mouse_hovered = true

func _on_mouse_exited() -> void:
	mouse_hovered = false
