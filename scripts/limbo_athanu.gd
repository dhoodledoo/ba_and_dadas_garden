extends Node2D


@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO

# items that hold the dragged ingredients
@onready var empty_bowl = $EmptyBowl
@onready var pot = $Pot
@onready var jar = $jar
#3rd set here

# the rest of the utensils that disappear after their phases finish
@onready var basket = $Basket
@onready var tumeric = $Tumeric
@onready var salt = $Salt

@onready var red_chilli = $RedChilli
@onready var kashmiri_chilli = $KashmiriChilli
@onready var empty_sugar = $EmptySugar
@onready var hing = $Hing
@onready var lemons2 = $Lemons2

@onready var coriander_seeds = $CorianderSeeds
@onready var empty_plate = $emptyplate


# Animations 
@onready var happy_ba = $Happy_Ba/happy_ba
@onready var shaking_pot = $shaking_pot/shaking_pot
@onready var finished_limbu = $finished_limbu/finished_limbu

@onready var wrong_order_node = $Wrong_Order
@onready var wrong_order_anim = $Wrong_Order/AnimationPlayer
@onready var wrong_order_sfx = $wrongordersfx

@onready var swaad = $swaad/swaad
@onready var swaadsfx = $swaadsfx

@onready var cooking = $cooking
# First set ingredients
@onready var lemons = $Lemons
@onready var small_tumeric = $SmallTumeric
@onready var small_salt = $SmallSalt

# Second set ingredients
@onready var small_red_chilli = $SmallRedChilli
@onready var small_kashmiri_chilli = $SmallKashmiriChilli
@onready var sugar = $Sugar
@onready var small_hing = $SmallHing
#labels:
@onready var hing_label = $hing_
@onready var sugar_label = $sugar_
@onready var redchilli_label = $redchilli_
@onready var kashmiri_label = $kashmiri_

# Third set ingredients
@onready var small_coriander_seeds = $SmallCorianderSeeds
@onready var methi_kuriya = $MethiKuriya
#labels:
@onready var methi_label = $methi_
@onready var coriander_label = $coriander_

var complete_first_set_nodes = []
var complete_second_set_nodes = []
var complete_third_set_nodes = []

var correct_order_first_set = ["lemons", "small_salt", "small_tumeric"]
var placed_order_first_set = []

var correct_order_second_set = ["sugar", "small_red_chilli", "small_kashmiri_chilli", "small_hing"]
var placed_order_second_set = []

var correct_order_third_set = ["methi_kuriya", "small_coriander_seeds"]
var placed_order_third_set = []


var in_first_set_phase = false
var in_second_set_phase = false
var in_third_set_phase = false


func _ready():
	wrong_order_sfx.stop()
	swaadsfx.stop()
	cooking.play()
	
	for ingredient in [lemons, small_salt, small_tumeric, sugar, small_red_chilli, small_kashmiri_chilli, small_hing, small_coriander_seeds, methi_kuriya]:
		ingredient.original_position = ingredient.position

	

	complete_first_set_nodes = [empty_bowl, lemons, small_salt, small_tumeric, basket, salt, tumeric]
	complete_second_set_nodes = [pot, sugar, small_red_chilli, small_kashmiri_chilli, small_hing, red_chilli, kashmiri_chilli, empty_sugar, hing, lemons2]
	complete_third_set_nodes = [jar, coriander_seeds, small_coriander_seeds, methi_kuriya, empty_plate]
	
	# animations are initally hidden 
	wrong_order_node.visible = false
	happy_ba.visible = false
	shaking_pot.visible = false
	finished_limbu.visible = false  
	swaad.visible = false
	# Connected ingredient drag_ended signals with correct argument order
	_connect_ingredient_signals()

	lemons.connect("drag_ended", Callable(self, "_on_lemons_drag_ended"))
	small_salt.connect("drag_ended", Callable(self, "_on_small_salt_drag_ended"))
	small_tumeric.connect("drag_ended", Callable(self, "_on_small_tumeric_drag_ended"))
	sugar.connect("drag_ended", Callable(self, "_on_sugar_drag_ended"))
	small_red_chilli.connect("drag_ended", Callable(self, "_on_small_red_chilli_drag_ended"))
	small_kashmiri_chilli.connect("drag_ended", Callable(self, "_on_small_kashmiri_chilli_drag_ended"))
	small_hing.connect("drag_ended", Callable(self, "_on_small_hing_drag_ended"))
	small_coriander_seeds.connect("drag_ended", Callable(self, "_on_small_coriander_seeds_drag_ended"))
	methi_kuriya.connect("drag_ended", Callable(self, "_on_small_methi_kuriya_drag_ended"))
	

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
	basket.visible = true
	tumeric.visible = true
	salt.visible = true

	red_chilli.visible = false
	kashmiri_chilli.visible = false
	empty_sugar.visible = false
	hing.visible = false
	lemons2.visible = false

	coriander_seeds.visible = false
	empty_plate.visible = false
	
	# visibility of items that hold the dragged ingredients
	empty_bowl.visible = true
	pot.visible = false
	jar.visible = false
	
	#2nd set is hidden 
	sugar.visible = false
	small_red_chilli.visible = false
	small_kashmiri_chilli.visible = false
	small_hing.visible = false
	
	#3rd set is hidden 
	small_coriander_seeds.visible = false 
	methi_kuriya.visible = false
	
	#visibility of labels
	hing_label.visible = false
	sugar_label.visible = false
	redchilli_label.visible = false
	kashmiri_label.visible = false
	
	methi_label.visible = false
	coriander_label.visible = false
	
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
	lemons.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(lemons, "lemons"))
	small_salt.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_salt, "small_salt"))
	small_tumeric.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_tumeric, "small_tumeric"))
	sugar.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(sugar, "sugar"))
	small_red_chilli.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_red_chilli, "small_red_chilli"))
	small_kashmiri_chilli.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_kashmiri_chilli, "small_kashmiri_chilli"))
	small_hing.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_hing, "small_hing"))
	small_coriander_seeds.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_coriander_seeds, "small_coriander_seeds"))
	methi_kuriya.connect("drag_ended",Callable(self, "_on_ingredient_drag_ended").bind(methi_kuriya, "methi_kuriya"))
	

func _connect_animation_signals():
	var wrong_order_callback = Callable(self, "_on_wrong_order_animation_finished")
	if wrong_order_anim.is_connected("animation_finished", wrong_order_callback):
		wrong_order_anim.disconnect("animation_finished", wrong_order_callback)
	wrong_order_anim.connect("animation_finished", wrong_order_callback)
	
	var happy_ba_callback = Callable(self, "_on_happy_ba_animation_finished")
	if happy_ba.is_connected("animation_finished", happy_ba_callback):
		happy_ba.disconnect("animation_finished", happy_ba_callback)
	happy_ba.connect("animation_finished", happy_ba_callback)
	
	var shaking_pot_callback = Callable(self, "_on_shaking_pot_animation_finished")
	if shaking_pot.is_connected("animation_finished", shaking_pot_callback):
		shaking_pot.disconnect("animation_finished", shaking_pot_callback)
	shaking_pot.connect("animation_finished", shaking_pot_callback)
	
	var finished_limbu_callback = Callable(self, "_on_finished_limbu_animation_finished")
	if finished_limbu.is_connected("animation_finished", finished_limbu_callback):
		finished_limbu.disconnect("animation_finished", finished_limbu_callback)
	finished_limbu.connect("animation_finished", finished_limbu_callback)

	var swaad_callback = Callable(self, "_on_swaad_animation_finished")
	if swaad.is_connected("animation_finished", swaad_callback):
		swaad.disconnect("animation_finished", swaad_callback)
	swaad.connect("animation_finished", swaad_callback)

func _on_ingredient_drag_ended(_drop_position: Vector2, ingredient_node: Node2D, ingredient_name: String):
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, false)
	set_nodes_interactive(complete_third_set_nodes, false)
	if _is_overlapping(ingredient_node, empty_bowl):
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
					empty_bowl.visible = false
					basket.visible = false 
					tumeric.visible = false 
					salt.visible = false 
					
			else:
				print("Wrong order in first set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_first_set, first_set_ingredients())
				placed_order_first_set.clear()
				in_first_set_phase = true
				empty_bowl.visible = true
				basket.visible = true
				tumeric.visible = true
				salt.visible = true
		
	if _is_overlapping(ingredient_node, pot):
		if in_second_set_phase:
			#visibility of labels
			hing_label.visible = true
			sugar_label.visible = true
			redchilli_label.visible = true
			kashmiri_label.visible = true
			set_nodes_interactive(complete_second_set_nodes, true) 
			if ingredient_name not in placed_order_second_set:
				placed_order_second_set.append(ingredient_name)
				print("Placed second set ingredient:", ingredient_name)
			
			if _check_order(placed_order_second_set, correct_order_second_set):
				if placed_order_second_set.size() == correct_order_second_set.size():
					_hide_ingredients(second_set_ingredients())
					_trigger_shaking_pot_animation()
					#2nd set
					pot.visible = true
					red_chilli.visible = true
					empty_sugar.visible = true
					kashmiri_chilli.visible = true
					hing.visible = true
					lemons2.visible = false 
					hing_label.visible = false
					sugar_label.visible = false
					redchilli_label.visible = false
					kashmiri_label.visible = false
					
			else:
				print("Wrong order in second set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_second_set, second_set_ingredients())
				placed_order_second_set.clear()
				#2nd set
				pot.visible = true
				red_chilli.visible = true
				empty_sugar.visible = true
				kashmiri_chilli.visible = true
				hing.visible = true
				lemons2.visible = true 
				#3rd set
				coriander_seeds.visible = false
				empty_plate.visible = false
				jar.visible = false
			
	if _is_overlapping(ingredient_node, jar):
		if in_third_set_phase:
			#visibility of labels
			hing_label.visible = false
			sugar_label.visible = false
			redchilli_label.visible = false
			kashmiri_label.visible = false
			methi_label.visible = true
			coriander_label.visible = true
			set_nodes_interactive(complete_third_set_nodes, true)
			if ingredient_name not in placed_order_third_set:
				placed_order_third_set.append(ingredient_name)
				print("Placed third set ingredient:", ingredient_name)
			
			if _check_order(placed_order_third_set, correct_order_third_set):
				if placed_order_third_set.size() == correct_order_third_set.size():
					_hide_ingredients(third_set_ingredients())
					_trigger_finished_limbu_animation()
					#3rd set
					in_third_set_phase = false
					coriander_seeds.visible = false
					empty_plate.visible = false
					jar.visible = false
					methi_label.visible = false
					coriander_label.visible = false
			
			else:
				print("Wrong order in second set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_third_set, third_set_ingredients())
				placed_order_third_set.clear()
				#2nd set
				in_third_set_phase = true
				coriander_seeds.visible = true
				empty_plate.visible = true
				jar.visible = true
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
		"lemons": lemons,
		"small_salt": small_salt,
		"small_tumeric": small_tumeric,
	}

func second_set_ingredients() -> Dictionary:
	return {
		"sugar": sugar,
		"small_red_chilli": small_red_chilli,
		"small_kashmiri_chilli": small_kashmiri_chilli,
		"small_hing": small_hing,
	}


func third_set_ingredients() -> Dictionary:
	return {
		"methi_kuriya": methi_kuriya,
		"small_coriander_seeds": small_coriander_seeds,
	}


func _hide_ingredients(ingredients: Dictionary):
	for node in ingredients.values():
		node.visible = false


func _trigger_shaking_pot_animation():
	print("shaking pot triggered")
	shaking_pot.position = Vector2(593, 228)
	shaking_pot.visible = true
	shaking_pot.play("shaking_pot")
	
func _on_shaking_pot_animation_finished():
	print("shaking pot finished")
	shaking_pot.visible = false 
	shaking_pot.stop()
	methi_label.visible = true
	coriander_label.visible = true
	# Transition to third set phase
	in_first_set_phase = false
	in_second_set_phase = false
	in_third_set_phase = true

	# Enable second set interactivity, disable others
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, false)
	set_nodes_interactive(complete_third_set_nodes, true)
	#3rd set
	coriander_seeds.visible = true
	small_coriander_seeds.visible = true
	empty_plate.visible = true
	methi_kuriya.visible = true
	jar.visible = true
	#2nd set
	pot.visible = false
	red_chilli.visible = false
	small_red_chilli.visible = false 
	empty_sugar.visible = false
	sugar.visible = false 
	kashmiri_chilli.visible = false
	small_kashmiri_chilli.visible = false 
	hing.visible = false
	small_hing.visible = false

	
	placed_order_second_set.clear()

func _trigger_finished_limbu_animation():
	print("finished limbu triggered")
	finished_limbu.position = Vector2(571, 313)
	finished_limbu.visible = true
	finished_limbu.play("finished_limbu")
	methi_label.visible = false
	coriander_label.visible = false

func _on_finished_limbu_animation_finished():
	print("finished limbu finished")
	finished_limbu.stop()
	finished_limbu.visible = true
	_trigger_swaad_animation()

func _trigger_happy_ba_animation():
	print("happy ba triggered")
	happy_ba.position = Vector2(551, 340)
	happy_ba.visible = true
	happy_ba.play("happy_ba")

func _on_happy_ba_animation_finished():
	print("happy ba animation finished")
	happy_ba.stop()
	happy_ba.visible = false
	#visibility of labels
	hing_label.visible = true
	sugar_label.visible = true
	redchilli_label.visible = true
	kashmiri_label.visible = true

# Transition to second set phase
	in_first_set_phase = false
	in_second_set_phase = true
	in_third_set_phase = false

	# Enable second set interactivity, disable others
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, true)
	set_nodes_interactive(complete_third_set_nodes, false)
		
	pot.visible = true
	lemons2.visible = true
	red_chilli.visible = true
	small_red_chilli.visible = true 
	empty_sugar.visible = true
	sugar.visible = true 
	kashmiri_chilli.visible = true
	small_kashmiri_chilli.visible = true 
	hing.visible = true
	small_hing.visible = true 
	
	placed_order_first_set.clear()
	


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
	get_tree().change_scene_to_file("res://scenes/ending_lemon.tscn")
	swaadsfx.stop()


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
	get_tree().change_scene_to_file("res://scenes/book_3.tscn")
