extends Control


var next_scene = preload("res://scenes/main_menu_test.tscn")



func _on_video_stream_player_finished():
	get_tree().change_scene_to_file(next_scene.resource_path)
"res://scenes/main_menu_test.tscn"
