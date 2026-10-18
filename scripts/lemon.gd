extends Area2D

var lemon_scene = preload("res://scenes/limbu_atahnu_cut_scene.tscn")


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var instance = lemon_scene.instantiate()
		get_parent().add_child(instance)  
		instance.global_position = position
		print("vegetable picked")
