extends Node2D



func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu_test.tscn")


func _on_next_pressed():
	get_tree().change_scene_to_file("res://scenes/recipe_2.tscn")
