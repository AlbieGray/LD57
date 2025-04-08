extends Control

@onready var start_position = position

func init(text):
	$Label.text = text

func _process(_delta):
	var fraction = ($Timer.time_left)/$Timer.wait_time
	position = start_position+Vector2(0, (1-fraction)*50)
	$Label.modulate = Color(255, 255, 255, 5*fraction)


func _on_timer_timeout() -> void:
	queue_free()
