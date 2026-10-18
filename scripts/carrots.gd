extends Area2D

var carrot_scene = preload("res://scenes/gajar_halwa_cut_scene.tscn")


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var instance = carrot_scene.instantiate()
		get_parent().add_child(instance)  
		instance.global_position = position
		print("vegetable picked")
