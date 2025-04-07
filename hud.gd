extends Control


func update_resource_counts(stone, food):
	$StoneLabel.text = "Stone: "+str(stone)
	$FoodLabel.text = "Food: "+str(food)

func _on_make_ant_button_pressed() -> void:
	get_parent().make_new_ant()


func _on_make_room_button_pressed() -> void:
	var currently_selected_ant = get_parent().selected_ant
	if currently_selected_ant != null:
		currently_selected_ant.make_room()
