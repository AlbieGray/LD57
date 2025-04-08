extends Node2D


const BLOCKADE_SPEED = 10

@onready var path = $BlockadePath
@onready var follower = $BlockadePath/BlockadeWalker

@onready var tilemap = get_parent().tilemap

@onready var ant = get_parent().selected_ant

func _ready() -> void:
	print("blockade_made")
	ant.blockading = true
	follower.loop = false
	var offset = path.curve.get_point_position(0)-ant.position
	for i in range(path.curve.point_count):
		path.curve.set_point_position(i, path.curve.get_point_position(i)-offset)

func _process(delta):
	if not $BuildBlockade.playing:
		$BuildBlockade.play()
	follower.progress += BLOCKADE_SPEED*delta
	position = follower.position
	
	var map_coords = tilemap.local_to_map(position)
	print(map_coords)
	tilemap.set_cell(map_coords, tilemap.tile_set.get_source_id(0), Vector2(5, 4))
	
	if follower.progress_ratio == 1:
		ant.play_blockade_finished()
		ant.blockading = false
		get_parent().blockades.erase(self)
		queue_free()
