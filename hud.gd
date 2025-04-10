extends Control

@onready var game = get_parent().get_parent()

func _ready():
	$MakeAntButton.text = "make new ant\n"+str(game.NEW_ANT_COST)+" Food"
	$MakeRoomButton.text = "make new room\n"+str(game.NEW_ROOM_COST)+" Stone"
	$MakeBlockadeButton.text = "make new blockade\n"+str(game.BLOCKADE_COST)+" Stone"
	update_button_visibility()

func update_resource_counts(stone, food, depth):
	$StoneLabel.text = "Stone: "+str(stone)
	$FoodLabel.text = "Food: "+str(food)
	$Label.text = "Depth: "+str(int(depth)-222)

func update_button_visibility(new_ant=false, make_room=false, make_blockade=false, distract=false):
	$MakeAntButton.visible = new_ant
	$MakeRoomButton.visible = make_room
	$MakeBlockadeButton.visible = make_blockade

func _on_make_ant_button_pressed() -> void:
	game.button_just_clicked = true
	game.make_new_ant()


func _on_make_room_button_pressed() -> void:
	game.button_just_clicked = true
	var currently_selected_ant = game.selected_ant
	if currently_selected_ant != null:
		currently_selected_ant.make_room()


func _on_make_blockade_button_pressed() -> void:
	game.button_just_clicked = true
	var currently_selected_ant = game.selected_ant
	if currently_selected_ant != null:
		currently_selected_ant.make_blockade()


func _on_distract_button_pressed() -> void:
	var currently_selected_ant = game.selected_ant
	if currently_selected_ant != null:
		game.tip.got_distracted(currently_selected_ant)
	pass # Replace with function body.
