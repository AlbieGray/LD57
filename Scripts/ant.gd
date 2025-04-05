extends CharacterBody2D

enum state{idle, following_path,}
var current_path_follow:PathFollow2D = null
var make_room_start_pos:Vector2 = Vector2(0, 0)

func _ready() -> void:
	set_velocity(Vector2(0, 0))

func _process(delta: float) -> void:
	if current_path_follow != null:
		current_path_follow.progress += 1
		position = make_room_start_pos + current_path_follow.position
		print(current_path_follow.h_offset)
		print(current_path_follow.v_offset)
		print()
	if Input.is_action_pressed("make_room"):
		make_room()

func make_room() -> void:
	current_path_follow = $RoomPath/PathFollow2D
	make_room_start_pos = current_path_follow.position-position

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	var coords = body.get_coords_for_body_rid(body_rid)
	body.set_cell(coords, body.tile_set.get_source_id(0), Vector2(1, 0))
