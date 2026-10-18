extends Node2D



@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO

# items that hold the dragged ingredients
@onready var pot = $BluePot
@onready var pot2 = $BluePot2


# the rest of the utensils that disappear after their phases finish
@onready var back_of_ghee = $BackOfGhee
@onready var front_of_ghee = $FrontOfGhee
@onready var empty_bowl = $EmptyBowl

@onready var sugar = $Sugar
@onready var cardomom_powder = $CardomomPowder
@onready var empty_plate = $Empty

# Animations 
@onready var happy_ba = $Happy_Ba/happy_ba
@onready var gas_and_fire = $gas_and_fire/gas_and_fire
@onready var gas_and_fire2 = $gas_and_fire2/gas_and_fire2
@onready var bubbling = $bubbling/bubbling
@onready var pouring_milk = $pouring_milk/pouring_milk
@onready var milky_carrots = $milky_carrots/milky_carrots
@onready var reduced_carrots = $reduced_carrots/reduced_carrots
@onready var finished_halwa = $finished_halwa/finished_halwa

@onready var wrong_order_node = $Wrong_Order
@onready var wrong_order_anim = $Wrong_Order/AnimationPlayer
@onready var wrong_order_sfx = $wrongordersfx

@onready var swaad = $swaad/swaad
@onready var swaadsfx = $swaadsfx

@onready var cooking = $cooking

# First set ingredients
@onready var milk = $Milk
@onready var grated_carrots = $GratedCarrots
@onready var ghee = $GheeSpoon
#labels
@onready var ghee_label = $ghee_

# Second set ingredients
@onready var small_sugar = $SmallSugar
@onready var small_cardomom = $SmallCradomom
@onready var nuts = $CrushedNuts


var complete_first_set_nodes = []
var complete_second_set_nodes = []

var correct_order_first_set = ["ghee", "grated_carrots", "milk"]
var placed_order_first_set = []

var correct_order_second_set = ["small_sugar", "small_cardomom", "nuts"]
var placed_order_second_set = []


var in_first_set_phase = false
var in_second_set_phase = false

var first_set_ingredients_dict = {}
var second_set_ingredients_dict = {}

func _ready():
	wrong_order_sfx.stop()
	swaadsfx.stop()
	cooking.play()
	
	# Initialize ingredient dictionaries
	first_set_ingredients_dict =  {
		"grated_carrots": grated_carrots,
		"ghee": ghee,
		"milk": milk,
	}

	second_set_ingredients_dict = {
		"small_sugar": small_sugar,
		"small_cardomom": small_cardomom,
		"nuts": nuts,
	}
	
	
	
	complete_first_set_nodes = [empty_bowl, back_of_ghee, front_of_ghee, milk, ghee, grated_carrots, pot]
	complete_second_set_nodes = [pot2, small_sugar, sugar, empty_plate, nuts, cardomom_powder, small_cardomom]
	
	# Store original positions for reset
	for ingredient in first_set_ingredients_dict.values():
		ingredient.original_position = ingredient.position
	for ingredient in second_set_ingredients_dict.values():
		ingredient.original_position = ingredient.position

	# animations are initally hidden 
	wrong_order_node.visible = false
	happy_ba.visible = false
	pouring_milk.visible = false
	bubbling.visible = false  
	milky_carrots.visible = false 
	reduced_carrots.visible = false
	finished_halwa.visible = false
	gas_and_fire2.visible = false
	swaad.visible = false
	
	gas_and_fire.visible = true
	gas_and_fire.play("gas_and_fire")
	gas_and_fire.position = Vector2(774.43, 248.96)
	
	#label
	ghee_label.visible = true

	# Connected ingredient drag_ended signals with correct argument order

	grated_carrots.connect("drag_ended", Callable(self, "_on_grated_carrots_ended"))
	ghee.connect("drag_ended", Callable(self, "_on_ghee_drag_ended"))
	milk.connect("drag_ended", Callable(self, "_on_milk_drag_ended"))
	small_sugar.connect("drag_ended", Callable(self, "_on_small_sugar_drag_ended"))
	small_cardomom.connect("drag_ended", Callable(self, "_on_small_cardomom_drag_ended"))
	nuts.connect("drag_ended", Callable(self, "_on_nuts_drag_ended"))

	for ingredient_name in first_set_ingredients_dict.keys():
		var node = first_set_ingredients_dict[ingredient_name]
		node.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(node, ingredient_name))

	for ingredient_name in second_set_ingredients_dict.keys():
		var node = second_set_ingredients_dict[ingredient_name]
		node.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(node, ingredient_name))

	_connect_animation_signals()

	# Starting with first_set ingredient phase active
	in_first_set_phase = true
	in_second_set_phase = false
	
	# Enable input only for the first set, disable others - hides the other sets makes them non interactive
	set_nodes_interactive(complete_first_set_nodes, true)
	set_nodes_interactive(complete_second_set_nodes, false)
	
	# visiblity of 1st, 2nd and 3rd set extra utensils
	empty_bowl.visible = true
	back_of_ghee.visible = true
	front_of_ghee.visible = true
	sugar.visible = false
	cardomom_powder.visible = false
	empty_plate.visible = false

	# visiblity of 2nd set ingredients
	small_sugar.visible = false
	nuts.visible = false
	small_cardomom.visible = false
	
	# visibility of items that hold the dragged ingredients
	pot.visible = true
	pot.position = Vector2(872, 201)
	pot2.visible = false
	
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
	var wrong_order_callback = Callable(self, "_on_wrong_order_animation_finished")
	if wrong_order_anim.is_connected("animation_finished", wrong_order_callback):
		wrong_order_anim.disconnect("animation_finished", wrong_order_callback)
	wrong_order_anim.connect("animation_finished", wrong_order_callback)
	
	var happy_ba_callback = Callable(self, "_on_happy_ba_animation_finished")
	if happy_ba.is_connected("animation_finished", happy_ba_callback):
		happy_ba.disconnect("animation_finished", happy_ba_callback)
	happy_ba.connect("animation_finished", happy_ba_callback)
	
	var gas_and_fire_callback = Callable(self, "_on_gas_and_fire_animation_finished")
	if gas_and_fire.is_connected("animation_finished", gas_and_fire_callback):
		gas_and_fire.disconnect("animation_finished", gas_and_fire_callback)
	gas_and_fire.connect("animation_finished", gas_and_fire_callback)

	var gas_and_fire2_callback = Callable(self, "_on_gas_and_fire2_animation_finished")
	if gas_and_fire2.is_connected("animation_finished", gas_and_fire2_callback):
		gas_and_fire2.disconnect("animation_finished", gas_and_fire2_callback)
	gas_and_fire2.connect("animation_finished", gas_and_fire2_callback)
	
	var bubbling_callback = Callable(self, "_on_bubbling_animation_finished")
	if bubbling.is_connected("animation_finished", bubbling_callback):
		bubbling.disconnect("animation_finished", bubbling_callback)
	bubbling.connect("animation_finished", bubbling_callback)

	var pouring_milk_callback = Callable(self, "_on_pouring_milk_animation_finished")
	if pouring_milk.is_connected("animation_finished", pouring_milk_callback):
		pouring_milk.disconnect("animation_finished", pouring_milk_callback)
	pouring_milk.connect("animation_finished", pouring_milk_callback)
	
	var milky_carrots_callback = Callable(self, "_on_milky_carrots_animation_finished")
	if milky_carrots.is_connected("animation_finished", milky_carrots_callback):
		milky_carrots.disconnect("animation_finished", milky_carrots_callback)
	milky_carrots.connect("animation_finished", milky_carrots_callback)

	var reduced_carrots_callback = Callable(self, "_on_reduced_carrots_animation_finished")
	if reduced_carrots.is_connected("animation_finished", reduced_carrots_callback):
		reduced_carrots.disconnect("animation_finished", reduced_carrots_callback)
	reduced_carrots.connect("animation_finished", reduced_carrots_callback)

	var finished_halwa_callback = Callable(self, "_on_finished_halwa_animation_finished")
	if finished_halwa.is_connected("animation_finished", finished_halwa_callback):
		finished_halwa.disconnect("animation_finished", finished_halwa_callback)
	finished_halwa.connect("animation_finished", finished_halwa_callback)

	var swaad_callback = Callable(self, "_on_swaad_animation_finished")
	if swaad.is_connected("animation_finished", swaad_callback):
		swaad.disconnect("animation_finished", swaad_callback)
	swaad.connect("animation_finished", swaad_callback)

func _on_ghee_drag_ended(_drop_position: Vector2):
	if in_first_set_phase:
		if _is_overlapping(ghee, pot):
			ghee.visible = false
			_trigger_bubbling_animation()
		else:
			ghee.position = ghee.original_position


func _on_ingredient_drag_ended(_drop_position: Vector2, ingredient_node: Node2D, ingredient_name: String):
	set_nodes_interactive(complete_first_set_nodes, false)
	set_nodes_interactive(complete_second_set_nodes, false)
	if _is_overlapping(ingredient_node, pot):
		if in_first_set_phase:
			set_nodes_interactive(complete_first_set_nodes, true)
			if ingredient_name not in placed_order_first_set:
				placed_order_first_set.append(ingredient_name)
				print("Placed first set ingredient:", ingredient_name)
			
			if _check_order(placed_order_first_set, correct_order_first_set):
				if placed_order_first_set.size() == correct_order_first_set.size():
					_hide_ingredients(first_set_ingredients())
					_trigger_pouring_milk_animation()
					#1st set
					in_first_set_phase = true
					gas_and_fire.visible = true
					pot.visible = true 
					empty_bowl.visible = false 
					back_of_ghee.visible = false
					front_of_ghee.visible = false
					ghee_label.visible = false
					
			else:
				print("Wrong order in first set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_first_set, first_set_ingredients())
				placed_order_first_set.clear()
				in_first_set_phase = true
				bubbling.visible = false
				gas_and_fire.visible = true
				gas_and_fire.position = Vector2(774.43, 248.96)
				empty_bowl.visible = true 
				back_of_ghee.visible = true
				front_of_ghee.visible = true
		
	if _is_overlapping(ingredient_node, pot):
		if in_second_set_phase:
			ghee_label.visible = false
			_trigger_gas_and_fire2_animation()
			_trigger_reduced_carrots_animation()
			set_nodes_interactive(complete_second_set_nodes, true) 
			if ingredient_name not in placed_order_second_set:
				placed_order_second_set.append(ingredient_name)
				print("Placed second set ingredient:", ingredient_name)
			
			if _check_order(placed_order_second_set, correct_order_second_set):
				if placed_order_second_set.size() == correct_order_second_set.size():
					_hide_ingredients(second_set_ingredients())
					_trigger_finished_halwa_animation()
					pot2.visible = true
					empty_plate.visible = true
					sugar.visible = true 
					cardomom_powder.visible = true
			else:
				print("Wrong order in second set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_second_set, second_set_ingredients())
				placed_order_second_set.clear()
				pot2.visible = true
				empty_plate.visible = true
				sugar.visible = true 
				cardomom_powder.visible = true
				
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
		"grated_carrots": grated_carrots,
		"ghee": ghee,
		"milk": milk,
	}

func second_set_ingredients() -> Dictionary:
	return {
		"small_sugar": small_sugar,
		"small_cardomom": small_cardomom,
		"nuts": nuts,
	}

func _hide_ingredients(ingredients: Dictionary):
	for node in ingredients.values():
		node.visible = false

func _trigger_bubbling_animation():
	print("bubbling triggered")
	bubbling.visible = true
	bubbling.play("bubbling")
	bubbling.position = Vector2(871, 174)

func _trigger_reduced_carrots_animation():
	print("reduced acrrots triggered")
	reduced_carrots.visible = true
	reduced_carrots.play("reduced_carrots")
	reduced_carrots.position = Vector2(-9280, 855.84)

func _trigger_milky_carrots_animation():
	print("milky carrots triggered")
	milky_carrots.visible = true
	milky_carrots.play("milky_carrots")
	milky_carrots.position = Vector2(873, 167)

func _trigger_happy_ba_animation():
	print("happy ba triggered")
	happy_ba.visible = true
	happy_ba.play("happy_ba")

func _trigger_finished_halwa_animation():
	print("finished halwa triggered")
	finished_halwa.visible = true
	finished_halwa.play("finished_halwa")
	finished_halwa.position = Vector2(483.75, 121)
	_on_reduced_carrots_animation_finished()
	
func _on_finished_halwa_animation_finished():
	_trigger_swaad_animation()
	finished_halwa.visible = true 
	finished_halwa.stop()
	gas_and_fire2.stop()
	
func _on_milky_carrots_animation_finished():
	print("milky carrots fin")
	in_first_set_phase = false
	in_second_set_phase = true
	milky_carrots.stop()
	_trigger_happy_ba_animation()

func _trigger_pouring_milk_animation():
	print("pouring milk triggered")
	pouring_milk.visible = true
	pouring_milk.play("pouring_milk")
	pouring_milk.position = Vector2(826,81)
	grated_carrots.visible = true

func _on_pouring_milk_animation_finished():
	print("pouring milk fin")
	pouring_milk.visible = false
	pouring_milk.stop()
	grated_carrots.visible = false
	bubbling.visible = false
	_trigger_milky_carrots_animation()

func _on_happy_ba_animation_finished():
	print("happy ba fin")
	set_nodes_interactive(complete_second_set_nodes, true) 
	set_nodes_interactive(complete_first_set_nodes, false) 
	in_first_set_phase = false
	in_second_set_phase = true
	happy_ba.stop()
	happy_ba.visible = false
	milky_carrots.visible = false
	_trigger_reduced_carrots_animation()
	empty_plate.visible = true
	nuts.visible = true 
	sugar.visible = true 
	small_sugar.visible = true
	cardomom_powder.visible = true
	small_cardomom.visible = true 
	gas_and_fire.visible = false 
	pot.visible = false
	_trigger_gas_and_fire2_animation()

func _trigger_gas_and_fire2_animation():
	gas_and_fire2.visible = true
	gas_and_fire2.play("gas_and_fire")
	if in_second_set_phase:
		gas_and_fire2.position = Vector2(382, 247)
		pot2.visible = true 
		pot2.position = Vector2(488, 197)

func _on_bubbling_animation_finished():
	print("bubbling fin")
	bubbling.visible = false
	bubbling.stop()

func _on_reduced_carrots_animation_finished():
	print("reduced carrots fin")
	reduced_carrots.visible = false
	reduced_carrots.stop()

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
	get_tree().change_scene_to_file("res://scenes/ending_gajar_halwa.tscn")
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
	get_tree().change_scene_to_file("res://scenes/book_2.tscn")
