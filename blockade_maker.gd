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
	follower.progress += BLOCKADE_SPEED*delta
	position = follower.position
	
	var map_coords = tilemap.local_to_map(position)
	print(map_coords)
	tilemap.set_cell(map_coords, tilemap.tile_set.get_source_id(0), Vector2(5, 4))
	
	if follower.progress_ratio == 1:
		ant.blockading = false
		get_parent().blockades.erase(self)
		queue_free()

#func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print(body)
	#if body is TileMapLayer:
		#var coords = body.get_coords_for_body_rid(body_rid)
		#var tile_type = tilemap.get_cell_atlas_coords(coords)
		#print(tile_type)
		#if tile_type == Vector2i(1, 0):
			#print(coords)
			#print("reinforcing")
			#body.set_cell(coords, body.tile_set.get_source_id(0), Vector2(4, 0))
