extends Node2D


@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO

# items that hold the dragged ingredients
@onready var colander = $colander
@onready var empty_bowl_2nd_set = $emptybowl2
@onready var empty_bowl_3rd_set = $emptybowl3rd

# the rest of the utensils that disappear after their phases finish
@onready var empty_bowl_1st_set = $EmptyBowl
@onready var empty_plate_2nd_set = $emptyplate
@onready var empty_plate_3rd_set = $emptyplate2 
@onready var empty_white_bowl_3rd_set = $emptybowlwhite
@onready var cheesecloth_3rd_set = $Cheesecloth2
@onready var sugar = $Sugar


# Animations 
@onready var happy_ba = $Happy_Ba/happy_ba
@onready var grating_mango = $Grating_mango/grating_mango
@onready var final_product = $Final_product/final_product

@onready var swaad = $swaad/swaad
@onready var swaadsfx = $swaadsfx
# Wrong order nodes
@onready var wrong_order_node = $Wrong_Order
@onready var wrong_order_anim = $Wrong_Order/AnimationPlayer
@onready var wrong_order_sfx = $wrongordersfx

@onready var cooking = $cooking

# First set ingredients
@onready var cheesecloth = $Cheesecloth
@onready var yogurt = $Yogurt

# Second set ingredients
@onready var sieve = $Sieve
@onready var mango = $Mango

# Third set ingredients
@onready var crushed_nuts = $CrushedNuts
@onready var dried_yogurt = $driedyogurt
@onready var mango_pulp = $MangoPulp
@onready var small_sugar = $SmallSugar

var complete_first_set_nodes = []
var complete_second_set_nodes = []
var complete_third_set_nodes = []

var correct_order_first_set = ["cheesecloth", "yogurt"]
var placed_order_first_set = []

var correct_order_second_set = ["sieve", "mango"]
var placed_order_second_set = []

var correct_order_third_set = ["dried_yogurt", "small_sugar", "mango_pulp", "crushed_nuts"]
var placed_order_third_set = []


var in_first_set_phase = false
var in_second_set_phase = false
var in_third_set_phase = false



func _ready():
	wrong_order_sfx.stop()
	swaadsfx.stop()
	cooking.play()
	
	for ingredient in [cheesecloth, yogurt, sieve, mango, dried_yogurt, small_sugar, mango_pulp, crushed_nuts]:
		ingredient.original_position = ingredient.position

	complete_first_set_nodes = [empty_bowl_1st_set, colander, cheesecloth, yogurt]
	complete_second_set_nodes = [empty_bowl_2nd_set, empty_plate_2nd_set, mango, sieve]
	complete_third_set_nodes = [empty_plate_3rd_set, empty_white_bowl_3rd_set, cheesecloth_3rd_set, dried_yogurt, sugar, small_sugar, mango_pulp, crushed_nuts]
	
	
	
	# animations are initally hidden 
	wrong_order_node.visible = false
	happy_ba.visible = false
	grating_mango.visible = false
	final_product.visible = false  
	swaad.visible = false
	# Connected ingredient drag_ended signals with correct argument order
	_connect_ingredient_signals()

	cheesecloth.connect("drag_ended", Callable(self, "_on_cheesecloth_drag_ended"))
	yogurt.connect("drag_ended", Callable(self, "_on_yogurt_drag_ended"))
	sieve.connect("drag_ended", Callable(self, "_on_sieve_drag_ended"))
	mango.connect("drag_ended", Callable(self, "_on_mango_drag_ended"))
	dried_yogurt.connect("drag_ended", Callable(self, "_on_dried_yogurt_drag_ended"))
	small_sugar.connect("drag_ended", Callable(self, "_on_small_sugar_drag_ended"))
	mango_pulp.connect("drag_ended", Callable(self, "_on_mango_pulp_drag_ended"))
	crushed_nuts.connect("drag_ended", Callable(self, "_on_crushed_nuts_drag_ended"))

	_connect_animation_signals()

	# Starting with first_set ingredient phase active
	in_first_set_phase = true
	in_second_set_phase = false
	in_third_set_phase = false
	
	# Enable input only for the first set, disable others - hides the other sets makes them non interactive
	set_nodes_interactive(complete_first_set_nodes, true)
	set_nodes_interactive(complete_second_set_nodes, false)
	set_nodes_interactive(complete_third_set_nodes, false)
	
	# visiblity of 1st, 2nd and 3rd set extra utensils
	empty_bowl_1st_set.visible = true 
	empty_plate_2nd_set.visible = false
	empty_plate_3rd_set.visible = false
	empty_white_bowl_3rd_set.visible = false
	cheesecloth_3rd_set.visible = false
	sugar.visible = false
	
	# visibility of items that hold the dragged ingredients
	colander.visible = true
	empty_bowl_2nd_set.visible = false 
	empty_bowl_3rd_set.visible = false
	
	#2nd set is hidden 
	sieve.visible = false 
	mango.visible = false 
	
	#3rd set is hidden 
	dried_yogurt.visible = false
	small_sugar.visible = false
	mango_pulp.visible = false 
	crushed_nuts.visible = false 
	
# making some of the nodes uninteractive when in different sets
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

func _connect_ingredient_signals(): 
	cheesecloth.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(cheesecloth, "cheesecloth"))
	yogurt.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(yogurt, "yogurt"))
	sieve.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(sieve, "sieve"))
	mango.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(mango, "mango"))
	dried_yogurt.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(dried_yogurt, "dried_yogurt"))
	small_sugar.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_sugar, "small_sugar"))
	mango_pulp.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(mango_pulp, "mango_pulp"))
	crushed_nuts.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(crushed_nuts, "crushed_nuts"))

func _connect_animation_signals():
	var wrong_order_callback = Callable(self, "_on_wrong_order_animation_finished")
	if wrong_order_anim.is_connected("animation_finished", wrong_order_callback):
		wrong_order_anim.disconnect("animation_finished", wrong_order_callback)
	wrong_order_anim.connect("animation_finished", wrong_order_callback)
	
	var happy_ba_callback = Callable(self, "_on_happy_ba_animation_finished")
	if happy_ba.is_connected("animation_finished", happy_ba_callback):
		happy_ba.disconnect("animation_finished", happy_ba_callback)
	happy_ba.connect("animation_finished", happy_ba_callback)
	
	var grating_mango_callback = Callable(self, "_on_grating_mango_animation_finished")
	if grating_mango.is_connected("animation_finished", grating_mango_callback):
		grating_mango.disconnect("animation_finished", grating_mango_callback)
	grating_mango.connect("animation_finished", grating_mango_callback)
	
	var final_product_callback = Callable(self, "_on_final_product_animation_finished")
	if final_product.is_connected("animation_finished", final_product_callback):
		final_product.disconnect("animation_finished", final_product_callback)
	final_product.connect("animation_finished", final_product_callback)
	
	var swaad_callback = Callable(self, "_on_swaad_animation_finished")
	if swaad.is_connected("animation_finished", swaad_callback):
		swaad.disconnect("animation_finished", swaad_callback)
	swaad.connect("animation_finished", swaad_callback)


func _on_ingredient_drag_ended(_drop_position: Vector2, ingredient_node: Node2D, ingredient_name: String):
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, false)
	set_nodes_interactive(complete_third_set_nodes, false)
	if _is_overlapping(ingredient_node, colander):
		if in_first_set_phase:
			set_nodes_interactive(complete_first_set_nodes, true)
			if ingredient_name not in placed_order_first_set:
				placed_order_first_set.append(ingredient_name)
				print("Placed first set ingredient:", ingredient_name)
			
			if _check_order(placed_order_first_set, correct_order_first_set):
				if placed_order_first_set.size() == correct_order_first_set.size():
					_hide_ingredients(first_set_ingredients())
					_trigger_happy_ba_animation()
					#1st set
					in_first_set_phase = false
					empty_bowl_1st_set.visible = false
					colander.visible = false 
			else:
				print("Wrong order in first set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_first_set, first_set_ingredients())
				placed_order_first_set.clear()
				empty_bowl_1st_set.visible = true
				colander.visible = true
		
	if _is_overlapping(ingredient_node, empty_bowl_2nd_set):
		if in_second_set_phase:
			set_nodes_interactive(complete_second_set_nodes, true) 
			if ingredient_name not in placed_order_second_set:
				placed_order_second_set.append(ingredient_name)
				print("Placed second set ingredient:", ingredient_name)
			
			if _check_order(placed_order_second_set, correct_order_second_set):
				if placed_order_second_set.size() == correct_order_second_set.size():
					_hide_ingredients(second_set_ingredients())
					_trigger_grating_mango_animation()
					#2nd set
					empty_bowl_2nd_set.visible = true
					empty_plate_2nd_set.visible = false
					
			else:
				print("Wrong order in second set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_second_set, second_set_ingredients())
				placed_order_second_set.clear()
				#2nd set
				empty_bowl_2nd_set.visible = true
				empty_plate_2nd_set.visible = true
				#3rd set
				empty_plate_3rd_set.visible = false
				empty_white_bowl_3rd_set.visible = false
				cheesecloth_3rd_set.visible = false
				sugar.visible = false 
			
	if _is_overlapping(ingredient_node, empty_bowl_3rd_set):
		if in_third_set_phase:
			set_nodes_interactive(complete_third_set_nodes, true)
			if ingredient_name not in placed_order_third_set:
				placed_order_third_set.append(ingredient_name)
				print("Placed third set ingredient:", ingredient_name)
			
			if _check_order(placed_order_third_set, correct_order_third_set):
				if placed_order_third_set.size() == correct_order_third_set.size():
					_hide_ingredients(third_set_ingredients())
					_trigger_final_product_animation()
					#3rd set
					in_third_set_phase = false
					empty_bowl_3rd_set.visible = true
					empty_plate_3rd_set.visible = true
					empty_white_bowl_3rd_set.visible = true
					cheesecloth_3rd_set.visible = true
					sugar.visible = true 
			else:
				print("Wrong order in second set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_third_set, third_set_ingredients())
				placed_order_third_set.clear()
				#3rd set
				empty_bowl_3rd_set.visible = true 
				empty_plate_3rd_set.visible = true
				empty_white_bowl_3rd_set.visible = true
				cheesecloth_3rd_set.visible = true
				sugar.visible = true 
	else:
		# Reset position if dropped outside pan
		ingredient_node.position = ingredient_node.original_position
	


func _check_order(placed: Array, correct: Array) -> bool:
	for i in range(placed.size()):
		if placed[i] != correct[i]:
			return false
	return true


# Reset ingredients on wrong order
func _reset_ingredients(placed: Array, ingredients: Dictionary):
	for ingredient_name in placed:
		var node = ingredients.get(ingredient_name, null)
		if node:
			node.visible = true
			node.position = node.original_position


# Ingredient node lookup dictionaries
func first_set_ingredients() -> Dictionary:
	return {
		"cheesecloth": cheesecloth,
		"yogurt": yogurt,
	}

func second_set_ingredients() -> Dictionary:
	return {
		"sieve": sieve,
		"mango": mango,
	}


func third_set_ingredients() -> Dictionary:
	return {
		"dried_yogurt": dried_yogurt,
		"small_sugar": small_sugar,
		"mango_pulp": mango_pulp,
		"crushed_nuts": crushed_nuts,
	}


func _hide_ingredients(ingredients: Dictionary):
	for node in ingredients.values():
		node.visible = false


func _trigger_final_product_animation():
	print("final product triggered")
	final_product.position = Vector2(639.25, 250.03)
	final_product.visible = true
	final_product.play("final_product")

func _on_final_product_animation_finished():
	print("final product animation finished")
	final_product.stop()
	final_product.visible = true 
	_trigger_swaad_animation()

func _trigger_grating_mango_animation():
	print("grating mango triggered")
	grating_mango.position = Vector2(563.81, 135.96)
	grating_mango.visible = true
	grating_mango.play("grating_mango")
	in_second_set_phase = false

func _on_grating_mango_animation_finished():
	print("grating mango animation finished")
	grating_mango.stop()
	grating_mango.visible = false
	empty_bowl_2nd_set.visible = false
	
	# Transition to third set phase
	in_first_set_phase = false
	in_second_set_phase = false
	in_third_set_phase = true
	
	# Enable third set interactivity, disable others
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, false)
	set_nodes_interactive(complete_third_set_nodes, true)
	
	#3rd set visible and put in place after animation finished
	empty_plate_3rd_set.visible = true
	empty_bowl_3rd_set.visible = true
	empty_white_bowl_3rd_set.visible = true
	cheesecloth_3rd_set.visible = true
	sugar.visible = true 
	small_sugar.visible = true
	crushed_nuts.visible = true
	mango_pulp.visible = true 
	dried_yogurt.visible = true
	
	placed_order_first_set.clear()
	placed_order_second_set.clear()
	

func _trigger_happy_ba_animation():
	print("happy ba triggered")
	happy_ba.position = Vector2(551, 340)
	happy_ba.visible = true
	happy_ba.play("happy_ba")

func _on_happy_ba_animation_finished():
	print("happy ba animation finished")
	happy_ba.stop()
	happy_ba.visible = false
# Transition to second set phase
	in_first_set_phase = false
	in_second_set_phase = true
	in_third_set_phase = false

	# Enable second set interactivity, disable others
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, true)
	set_nodes_interactive(complete_third_set_nodes, false)
		
	empty_bowl_2nd_set.visible = true
	empty_plate_2nd_set.visible = true
	mango.visible = true
	sieve.visible = true
	
	placed_order_first_set.clear()
	placed_order_third_set.clear()


func _trigger_wrong_order_animation():
	print("Wrong order triggered")
	wrong_order_node.visible = true
	wrong_order_anim.play("wrong_order")
	wrong_order_sfx.play()


func _on_wrong_order_animation_finished():
	print("Wrong order animation finished")
	wrong_order_anim.stop()
	wrong_order_node.visible = false
	wrong_order_sfx.stop()

func _trigger_swaad_animation():
	print("swaad!")
	swaad.visible = true 
	swaad.play("swaad")
	swaadsfx.play()
	cooking.stop()

func _on_swaad_animation_finished():
	get_tree().change_scene_to_file("res://scenes/ending_mango.tscn")
	swaadsfx.stop()

# Overlap detection
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
	get_tree().change_scene_to_file("res://scenes/book_4.tscn")
