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

func make_new_ant():
	if selected_ant == null:
		print("select an ant first!")
		return
	else:
		var new_ant = ant_scene.instantiate()
		new_ant.line = $LineDrawer/Line2D
		new_ant.tilemap = $Ground/TileMapLayer
		add_child(new_ant)

func _ready():
	$Ant.line = $LineDrawer/Line2D
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
		print("changing rope length")
		rope.extend_rope(end)
		rope.shrink_rope(end)
