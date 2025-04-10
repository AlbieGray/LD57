extends Node2D

var RopePiece = preload("res://Scenes/rope/tongue_chain.tscn")
var rope_parts := []
var piece_length := 20.0
var rope_close_tolerance := 18.0
var rope_points : PackedVector2Array = []
var distance
var end 
var tip

@onready var ropeStart = $ropeStart
@onready var ropeEnd = $ropeEnd
@onready var ropeStartJoint = $ropeStart/Col/Pin
@onready var ropeEndJoint = $ropeEnd/Col/Pin

func _ready():
	tip = get_parent().get_node("Tongue")
	var start = get_child(0).global_position
	end = tip.global_position
	spawn_rope(start, end)
	
func _process(_delta):
	end = tip.global_position
	extend_rope(end)
	#shrink_rope(end)
	
#called to initialise rope
func spawn_rope(start: Vector2, end: Vector2):
	ropeStart.global_position = start
	ropeEnd.global_position = end
	start = ropeStartJoint.global_position
	end = ropeEndJoint.global_position
	
	distance = start.distance_to(end)
	var segments = round(distance/piece_length)
	var angle = (end - start).angle() - PI/2
	create_rope(segments, ropeStart, end, angle)

#called to extend rope by 1 segment when endpoint moves more than 1 piece_length away from prev.
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

#called to shrink the rope when back tracking.
func shrink_rope(end: Vector2):
	var last_chain = rope_parts[-1]
	var new_dist = last_chain.global_position.distance_to(end)
	if(new_dist <= rope_close_tolerance and rope_parts.size() != 1):
		var popped = rope_parts.pop_back()
		ropeEnd.global_position = popped.global_position
		popped.queue_free()
		end = ropeEndJoint.global_position
		ropeEndJoint.node_a = ropeEnd.get_path()
		ropeEndJoint.node_b = rope_parts[-1].get_path()
		distance = ropeStartJoint.global_position.distance_to(end)
	pass
		
#actual method to instantiate all the rope segments
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

#method to add segment when given an origin (parent), id (for debug), and angle (to orient the segment)
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
	
#needed for rope initialisation
func create_rope_points():
	rope_points = []
	rope_points.append(ropeStartJoint.global_position)
	for r in rope_parts:
		rope_points.append(r.global_position)
	rope_points.append(ropeEndJoint.global_position)
		
#the blue line u see on the rope (for debug)
func _draw():
	draw_polyline(rope_points, Color.BLUE)
