extends Node2D

var RopePiece = preload("res://Scenes/rope/tongue_chain.tscn")
var rope_parts := []
var piece_length := 23.0
var rope_close_tolerance := 20.0
var rope_points : PackedVector2Array = []
var distance

@onready var ropeStart = $ropeStart
@onready var ropeEnd = $ropeEnd
@onready var ropeStartJoint = $ropeStart/Col/Pin
@onready var ropeEndJoint = $ropeEnd/Col/Pin

func _process(delta):
	create_rope_points()
	if !rope_points.is_empty():
		queue_redraw()
	

func spawn_rope(start: Vector2, end: Vector2):
	ropeStart.global_position = start
	ropeEnd.global_position = end
	start = ropeStartJoint.global_position
	end = ropeEndJoint.global_position
	
	distance = start.distance_to(end)
	var segments = round(distance/piece_length)
	var angle = (end - start).angle() - PI/2
	create_rope(segments, ropeStart, end, angle)
	
func extend_rope(end: Vector2):
	if(ropeEnd.get_node("Col/Pin").global_position.distance_to(end) >= piece_length):
		ropeEnd.global_position = end
		end = ropeEndJoint.global_position
		var last_chain = rope_parts[-1]
		var angle = (end - last_chain.get_node("Col/Pin").global_position).angle() - PI/2
		var next_chain = add_piece(last_chain, 0, angle)
		rope_parts.append(next_chain)
		ropeEndJoint.node_a = ropeEnd.get_path()
		ropeEndJoint.node_b = rope_parts[-1].get_path()
		distance = ropeStartJoint.global_position.distance_to(end)

func shrink_rope(end: Vector2):
	var last_chain = rope_parts[-1]
	var new_dist = last_chain.global_position.distance_to(end)
	if(new_dist <= piece_length/2 and rope_parts.size() != 1):
		var popped = rope_parts.pop_back()
		ropeEnd.global_position = popped.global_position
		popped.queue_free()
		end = ropeEndJoint.global_position
		ropeEndJoint.node_a = ropeEnd.get_path()
		ropeEndJoint.node_b = rope_parts[-1].get_path()
		distance = ropeStartJoint.global_position.distance_to(end)
	pass
		
func create_rope(amount:int, parent:Object, end:Vector2, angle:float) -> void:
	for i in amount:
		parent = add_piece(parent, i, angle)
		parent.set_name("rope" + str(i))
		rope_parts.append(parent)
		
		var joint_pos = parent.get_node("Col/Pin").global_position
		if joint_pos.distance_to(end) < rope_close_tolerance:
			break
	ropeEndJoint.node_a = ropeEnd.get_path()
	ropeEndJoint.node_b = rope_parts[-1].get_path()

func add_piece(parent:Object, id:int, angle:float) -> Object:
	var joint = parent.get_node("Col/Pin") as PinJoint2D
	var piece = RopePiece.instantiate() as Object
	piece.global_position = joint.global_position
	piece.rotation = angle
	piece.parent = self
	piece.id = id
	add_child(piece)
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	
	return piece
	
func create_rope_points():
	rope_points = []
	rope_points.append(ropeStartJoint.global_position)
	for r in rope_parts:
		rope_points.append(r.global_position)
	rope_points.append(ropeEndJoint.global_position)
		
func _draw():
	draw_polyline(rope_points, Color.BLUE)
