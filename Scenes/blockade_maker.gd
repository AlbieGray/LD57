extends Node2D


const BLOCKADE_SPEED = 10

@onready var follower = $BlockadePath/BlockadeWalker

func _ready() -> void:
	print("blockade_made")

func _process(delta):
	follower.progress += BLOCKADE_SPEED*delta
	position = follower.position
	
