extends Node

var selected_ant = null
var ants = []

var ant_scene = preload("res://Scenes/Ant.tscn")

# rope stuff
var Rope = preload("res://Scenes/rope/rope.tscn")
var start := Vector2.ZERO
var end := Vector2.ZERO
var rope 
@onready var tip = $Tongue

var stone = 0
var food = 0

const NEW_ANT_COST = 50
const NEW_ROOM_COST = 50

var dragging_camera = false
var camera_drag_previous_point = Vector2(0, 0)

func make_new_ant():
	if selected_ant == null:
		print("select an ant first!")
		return
	if food <= NEW_ANT_COST:
		print("not enough food!")
		return
	food -= NEW_ANT_COST
	update_gui()
	var new_ant = ant_scene.instantiate()
	var rng = RandomNumberGenerator.new()
	new_ant.position = selected_ant.position + Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
	new_ant.tilemap = $Ground/TileMapLayer
	add_child(new_ant)

func update_gui():
	$CanvasLayer/HUD.update_resource_counts(stone, food)

func _ready():
	#$Ant.line = $LineDrawer/Line2D
	$Ant.tilemap = $Ground/TileMapLayer
	
	rope = Rope.instantiate()
	start = rope.get_child(0).global_position
	end = tip.global_position
	add_child(rope)
	rope.spawn_rope(start, end)

func _process(_delta: float) -> void:
	var past = end
	end = tip.global_position
	if end != Vector2.ZERO and end != past:
		rope.extend_rope(end)
		rope.shrink_rope(end)
	
	if Input.is_action_just_pressed("leftMouse"):
		dragging_camera = true
		camera_drag_previous_point = get_viewport().get_mouse_position()
	elif Input.is_action_pressed("leftMouse"):
		var delta = camera_drag_previous_point - get_viewport().get_mouse_position()
		$Camera.position += delta
		
		camera_drag_previous_point = get_viewport().get_mouse_position()
	
