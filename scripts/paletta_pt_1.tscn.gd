extends Node2D

@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO

#items that hold the draggables
@onready var chopping_board = $ChoppingBoard
@onready var water_bowl = $WaterBowl

#extra utensils
#1st set
@onready var knife = $Knife
@onready var chopped_aubergine = $ChoppedAubergine
@onready var chopped_potato = $ChoppedPotato
@onready var veg = $Veg
# Animations 
@onready var happy_ba = $Happy_Ba/happy_ba

# First set ingredients (2 phases in the 1st set, so its split into 2)
@onready var aubergine = $Aubergine
@onready var potato = $Potato
# Second set ingredients
@onready var chopped_veg = $ChoppedVeg

var aubergine_cut = false
var potato_cut = false

var in_first_set_phase = false
var in_second_set_phase = false

func _ready():

	
	for ingredient in [aubergine, potato, chopped_veg]:
		ingredient.original_position = ingredient.position
	

	# animations are initially hidden 
	happy_ba.visible = false
	
	#items that hold the draggables
	chopping_board.visible = true
	water_bowl.visible = true
	
	chopped_aubergine.visible = false
	chopped_potato.visible = false
	chopped_veg.visible = false
	veg.visible = false
	
	aubergine.connect("drag_ended", Callable(self, "_on_aubergine_drag_ended"))
	potato.connect("drag_ended", Callable(self, "_on_potato_drag_ended"))
	chopped_veg.connect("drag_ended", Callable(self, "_on_chopped_veg_drag_ended"))
	
	_connect_animation_signals()
	
	# Starting with first_set ingredient phase active
	in_first_set_phase = true
	in_second_set_phase = false

func set_node_interactive(node: Node, interactive: bool) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	if node.has_method("set_process_input"):
		node.set_process_input(interactive)
	if node.has_method("set_process_unhandled_input"):
		node.set_process_unhandled_input(interactive)

func set_nodes_interactive(nodes: Array, interactive: bool) -> void:
	for node in nodes:
		set_node_interactive(node, interactive)

func _connect_animation_signals():
	var happy_ba_callback = Callable(self, "_on_happy_ba_animation_finished")
	if happy_ba.is_connected("animation_finished", happy_ba_callback):
		happy_ba.disconnect("animation_finished", happy_ba_callback)
	happy_ba.connect("animation_finished", happy_ba_callback)

func _on_aubergine_drag_ended(_drop_position: Vector2):
	if in_first_set_phase:
		if _is_overlapping(aubergine, chopping_board):
			print("aubergine cut")
			aubergine.visible = false
			chopped_aubergine.visible = true
			set_node_interactive(aubergine, false)
			aubergine_cut = true
			_check_first_set_completion()
		else:
			print("wrong")
			aubergine.position = aubergine.original_position
			aubergine.visible = true
			set_node_interactive(aubergine, true)

func _on_potato_drag_ended(_drop_position: Vector2):
	if in_first_set_phase:
		if _is_overlapping(potato, chopping_board):
			print("potato cut")
			potato.visible = false
			chopped_potato.visible = true
			set_node_interactive(potato, false)
			potato_cut = true
			_check_first_set_completion()
		else:
			print("wrong")
			potato.position = potato.original_position
			potato.visible = true
			set_node_interactive(potato, true)

func _check_first_set_completion():
	if aubergine_cut and potato_cut:
		print("First set complete, activating second set")
		in_first_set_phase = false
		in_second_set_phase = true
		
		# Show and enable chopped_veg
		chopped_veg.visible = true
		chopped_aubergine.visible = false 
		chopped_potato.visible = false
		knife.visible = false
		set_node_interactive(chopped_veg, true)
		set_nodes_interactive([aubergine, potato, chopping_board], false)

func _on_chopped_veg_drag_ended(_drop_position: Vector2):
	if in_second_set_phase:
		chopped_aubergine.visible = false
		chopped_potato.visible = false
		set_node_interactive(chopped_veg, true)
		if _is_overlapping(chopped_veg, water_bowl):
			print("splash")
			chopped_veg.visible = false
			veg.visible = true
			in_second_set_phase = false
			_trigger_happy_ba_animation()
		else:
			print("wrong")
			chopped_veg.position = chopped_veg.original_position
			chopped_veg.visible = true

func _trigger_happy_ba_animation():
	print("happy ba triggered")
	happy_ba.position = Vector2(551, 340)
	happy_ba.visible = true
	happy_ba.play("happy_ba")
	# Start a timer before changing scene
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1  # seconds, adjust as needed
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_happy_ba_timer_timeout"))
	timer.start()

func _on_happy_ba_timer_timeout():
	happy_ba.stop()
	happy_ba.visible = false
	get_tree().change_scene_to_file("res://scenes/paletta_pt_2.tscn")

func _on_happy_ba_animation_finished():
	print("happy ba finished")
	happy_ba.stop()
	happy_ba.visible = false


func _is_overlapping(node_a: Node2D, node_b: Node2D) -> bool:
	var a_texture_size = Vector2.ZERO
	var b_texture_size = Vector2.ZERO

	if node_a is Sprite2D and node_a.texture:
		a_texture_size = node_a.texture.get_size()
	elif node_a is AnimatedSprite2D and node_a.sprite_frames:
		var frame_tex = node_a.sprite_frames.get_frame_texture(node_a.animation, node_a.frame)
		if frame_tex:
			a_texture_size = frame_tex.get_size()

	if node_b is Sprite2D and node_b.texture:
		b_texture_size = node_b.texture.get_size()
	elif node_b is AnimatedSprite2D and node_b.sprite_frames:
		var frame_tex = node_b.sprite_frames.get_frame_texture(node_b.animation, node_b.frame)
		if frame_tex:
			b_texture_size = frame_tex.get_size()

	var rect_a = Rect2(node_a.global_position - a_texture_size / 2, a_texture_size)
	var rect_b = Rect2(node_b.global_position - b_texture_size / 2, b_texture_size)

	return rect_a.intersects(rect_b)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/book_1.tscn")
