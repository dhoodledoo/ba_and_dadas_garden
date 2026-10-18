extends Node2D

@onready var loading = $loading

# Dictionary
var button_to_next_scene = {
	"aubergine": "res://scenes/paletta_cut_scene.tscn",
	"lemons": "res://scenes/limbu_atahnu_cut_scene.tscn",
	"mango": "res://scenes/mango_shrikand_cut_scene.tscn",
	"tomatoes": "res://scenes/tomato_cut_scene.tscn",
	"carrots": "res://scenes/gajar_halwa_cut_scene.tscn"
}

# Track the last pressed button
var last_pressed_button: String = ""

func _ready():
	loading.connect("finished", _on_loading_finished)
	loading.visible = false 
	loading.stop()

func play_loading_and_set_next_scene(button_name: String):
	last_pressed_button = button_name
	loading.play()
	loading.visible = true
	set_process_input(false)  # Disable input while video plays

func _on_loading_finished():
	print("Last pressed button: ", last_pressed_button) 
	if button_to_next_scene.has(last_pressed_button):
		var next_scene = button_to_next_scene[last_pressed_button]
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Error: No scene mapped for button: ", last_pressed_button)
	set_process_input(true) 

func _on_aubergine_pressed():
	play_loading_and_set_next_scene("aubergine")

func _on_lemons_pressed():
	play_loading_and_set_next_scene("lemons")

func _on_mango_pressed():
	play_loading_and_set_next_scene("mango")

func _on_tomatoes_pressed():
	play_loading_and_set_next_scene("tomatoes")

func _on_carrots_pressed():
	play_loading_and_set_next_scene("carrots")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu_test.tscn")
