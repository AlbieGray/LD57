extends Control

@onready var game = get_parent().get_parent()

func update_resource_counts(stone, food):
	$StoneLabel.text = "Stone: "+str(stone)
	$FoodLabel.text = "Food: "+str(food)

func update_button_visibility(new_ant=true, make_room=true):
	$MakeAntButton.visible = new_ant
	$MakeRoomButton.visible = make_room

func _on_make_ant_button_pressed() -> void:
	game.button_just_clicked = true
	game.make_new_ant()


func _on_make_room_button_pressed() -> void:
	game.button_just_clicked = true
	var currently_selected_ant = game.selected_ant
	if currently_selected_ant != null:
		currently_selected_ant.make_room()
