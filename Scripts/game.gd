extends Node

var selected_ant = null
var ants = []

var ant_scene = preload("res://Scenes/Ant.tscn")

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
