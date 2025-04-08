extends Node

var selected_ant = null

var ant_scene = preload("res://Scenes/Ant.tscn")
var line_scene = preload("res://Scenes/line_drawer.tscn")
var room_scene = preload("res://Scenes/room.tscn")
var blockade_scene = preload("res://Scenes/blockade_maker.tscn")
var error_message_scene = preload("res://Scenes/error_message.tscn")

# rope stuff
var Rope = preload("res://Scenes/rope/rope.tscn")
var start := Vector2.ZERO
var end := Vector2.ZERO
var rope 
@onready var tip = $Tongue

var stone = 0
var food = 0

var NEW_ANT_COST = 50
const NEW_ROOM_COST = 50
const BLOCKADE_COST = 100

var blockade_tiles = []
const BLOCKADE_DECAY_RATE = 1
 

var dragging_camera = false
var camera_drag_previous_point = Vector2(0, 0)

var ants = []
var blockades = []

var button_just_clicked = false

@onready var tilemap = $Ground/TileMapLayer

func error_message(text):
	var error = error_message_scene.instantiate()
	add_child(error)
	error.init(text)

func make_new_ant():
	if selected_ant == null:
		print("select an ant first!")
		error_message("select an ant first!")
		return
	if food <= NEW_ANT_COST:
		print("not enough food!")
		error_message("not enough food!")
		return
	
	var in_room = false
	for thing in selected_ant.find_child("Area2D").get_overlapping_areas():
		print(thing.name)
		if thing.name == "RoomArea":
			in_room = true
	if not in_room:
		print("must be in a room to make a new ant")
		error_message("must be in a room to make a new ant")
		return
		
	food -= NEW_ANT_COST
	NEW_ANT_COST *= 2
	update_gui()
	var new_ant = ant_scene.instantiate()
	
	var rng = RandomNumberGenerator.new()
	new_ant.position = selected_ant.position + Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
	new_ant.tilemap = $Ground/TileMapLayer
	add_child(new_ant)
	new_ant.pick_sprite()
	
	ants.append(new_ant)

func kill_ant(ant):
	$SFX/AntDeath.play()
	for blockade in blockades:
		if blockade.ant == ant:
			blockades.erase(blockade)
			blockade.queue_free()
	if(ant.queen):
		$CanvasLayer/over.show()
		$CanvasLayer/HUD.hide()
		pass
	ant.queue_free()
	ants.erase(ant)
	selected_ant = null
	
	update_gui()

func update_gui():
	$CanvasLayer/HUD.update_resource_counts(stone, food)
	var show_make_ant_button = false
	var show_make_room_button = false
	var show_make_blockade_button = false
	var show_distract_button = false
	if selected_ant != null:
		show_make_ant_button = selected_ant.queen
		show_make_room_button = true
		show_make_blockade_button = true
		show_distract_button = true
	
	$CanvasLayer/HUD.update_button_visibility(show_make_ant_button, 
		show_make_room_button,
		show_make_blockade_button, show_distract_button)

func draw_line():
	var line_drawer = line_scene.instantiate()
	selected_ant.line = line_drawer.find_child("Line2D")
	add_child(line_drawer)

func add_room():
	var room_position = selected_ant.position
	var new_room = room_scene.instantiate()
	add_child(new_room)
	new_room.position = room_position

func make_blockade():
	print("making blockade")
	var blockader = blockade_scene.instantiate()
	add_child(blockader)
	blockader.position = selected_ant.position
	blockades.append(blockader)

func _ready():
	$Ant.tilemap = $Ground/TileMapLayer
	$Ant.queen = true
	$Ant.selected = true
	$Ant.display_name = "Queen \n"+ $Ant.display_name
	$Ant/NameTag.text = $Ant.display_name
	
	selected_ant = $Ant
	ants = [$Ant]
	
	update_gui()
	
	rope = Rope.instantiate()
	start = rope.get_child(0).global_position
	end = tip.global_position
	add_child(rope)
	
func reset_rope():
	rope.queue_free()
	rope = Rope.instantiate()
	start = rope.get_child(0).global_position
	end = tip.global_position
	add_child(rope)

func _process(delta: float) -> void:
	var past = end
	end = tip.global_position
	if end != Vector2.ZERO and end != past:
		rope.extend_rope(end)
		rope.shrink_rope(end)
	
	if Input.is_action_just_pressed("leftMouse"):
		$SFX/Click.play()
		dragging_camera = true
		camera_drag_previous_point = get_viewport().get_mouse_position()
	elif Input.is_action_pressed("leftMouse"):
		var camera_delta = camera_drag_previous_point - get_viewport().get_mouse_position()
		$Camera.position += camera_delta
		
		camera_drag_previous_point = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("leftMouse") and not button_just_clicked:
		selected_ant = null
		for ant in ants:
			ant.selected = false
			ant.find_child("SelectedRing").visible = false
			if ant.mouse_hovered:
				selected_ant = ant
		if selected_ant != null:
			selected_ant.selected = true
			selected_ant.find_child("SelectedRing").visible = true
		update_gui()
	
	for blockade_tile in blockade_tiles:
		var rand = randf()
		if rand < delta*BLOCKADE_DECAY_RATE:
			tilemap.set_cell(blockade_tile, tilemap.tile_set.get_source_id(0), Vector2(1, 0))
	
	button_just_clicked = false
	
	
