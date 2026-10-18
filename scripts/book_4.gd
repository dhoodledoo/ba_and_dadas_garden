extends Node2D




func _on_next_pressed():
	get_tree().change_scene_to_file("res://scenes/mango_shrikand.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/garden.tscn")
