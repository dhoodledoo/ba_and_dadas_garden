extends CollisionShape2D


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("vegetable picked")
			get_tree().change_scene_to_file("res://mango_shrikand_cut_scene.tscn")
