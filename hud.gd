extends Control


func _on_make_ant_button_pressed() -> void:
	print("button pressed")
	get_parent().make_new_ant()


func _on_make_room_button_pressed() -> void:
	get_parent().selected_ant.make_room()
