extends Node2D

@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO


@onready var oil = $oil
@onready var pan = $pan

# Animations 
@onready var gas_and_fire = $gasandfire/AnimatedSprite2D
@onready var spoon_node = $spoon
@onready var spoon = $spoon/spoon
@onready var bubbling_node = $bubbling
@onready var bubbling = $bubbling/bubbling
@onready var first_set_node = $first_set
@onready var first_set = $first_set/first_set
@onready var happy_ba = $Happy_Ba/happy_ba 
@onready var happy_ba_node = $Happy_Ba

# Wrong order nodes
@onready var wrong_order_node = $Wrong_Order
@onready var wrong_order_anim = $Wrong_Order/AnimationPlayer
@onready var wrong_order_sfx = $wrongordersfx

@onready var cooking = $cooking
# First set ingredients
@onready var small_hing = $SmallHing
@onready var jeeru = $Jeeru
@onready var spring_onion = $ChoppedSpringOnion

#labels
@onready var hing_label = $hing_
@onready var cumin_label = $cumin



var correct_order_first_set = ["jeeru", "small_hing", "spring_onion"]
var placed_order_first_set = []




func _ready():
	wrong_order_sfx.stop()
	cooking.play()
	for ingredient in [small_hing, jeeru, spring_onion, oil]:
		ingredient.original_position = ingredient.position

	

	gas_and_fire.visible = true
	gas_and_fire.play("gas_and_fire")
	# animations are initally hidden 
	spoon.visible = false
	bubbling.visible = false
	first_set.visible = false
	happy_ba.visible = false
	wrong_order_node.visible = false
	# Connected ingredient drag_ended signals with correct argument order
	_connect_ingredient_signals()

	
	oil.connect("drag_ended", Callable(self, "_on_oil_drag_ended"))

	_connect_animation_signals()



func _connect_ingredient_signals():
	# First set ingredients
	small_hing.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_hing, "small_hing"))
	jeeru.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(jeeru, "jeeru"))
	spring_onion.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(spring_onion, "spring_onion"))
	


func _connect_animation_signals():
	var spoon_callback = Callable(self, "_on_spoon_animation_finished")
	if spoon.is_connected("animation_finished", spoon_callback):
		spoon.disconnect("animation_finished", spoon_callback)
	spoon.connect("animation_finished", spoon_callback)

	var bubbling_callback = Callable(self, "_on_bubbling_animation_finished")
	if bubbling.is_connected("animation_finished", bubbling_callback):
		bubbling.disconnect("animation_finished", bubbling_callback)
	bubbling.connect("animation_finished", bubbling_callback)

	var first_set_callback = Callable(self, "_on_first_set_animation_finished")
	if first_set.is_connected("animation_finished", first_set_callback):
		first_set.disconnect("animation_finished", first_set_callback)
	first_set.connect("animation_finished", first_set_callback) 
	
	var happy_ba_callback = Callable(self, "_on_happy_ba_animation_finished")
	if happy_ba.is_connected("animation_finished", happy_ba_callback):
		happy_ba.disconnect("animation_finished", happy_ba_callback)
	happy_ba.connect("animation_finished", happy_ba_callback)

	var wrong_order_callback = Callable(self, "_on_wrong_order_animation_finished")
	if wrong_order_anim.is_connected("animation_finished", wrong_order_callback):
		wrong_order_anim.disconnect("animation_finished", wrong_order_callback)
	wrong_order_anim.connect("animation_finished", wrong_order_callback)


# Oil drag ends triggers spoon animation
func _on_oil_drag_ended(_drop_position: Vector2):
	if _is_overlapping(oil, pan):
		oil.visible = false
		spoon.position = Vector2(681, 82)
		spoon.visible = true
		spoon.play("spoon")
	else:
		oil.position = oil.original_position


func _on_spoon_animation_finished():
	if spoon.animation == "spoon":
		spoon.visible = false
		spoon.stop()
		bubbling.position = Vector2(683, 144)
		bubbling.visible = true
		bubbling.play("bubbling")
		is_dragging = false
		drag_offset = position + pan.position
	elif not pan.pressed and is_dragging:
		is_dragging = true 
	else:
		spoon.stop()
		spoon.visible = false
		oil.position = oil.original_position
		oil.visible = true


func _on_bubbling_animation_finished():
	if bubbling.animation == "bubbling":
		print("Bubbling animation finished, first set phase enabled")
		bubbling.visible = false
		bubbling.stop()
		first_set.position = Vector2(33.41, -35.94)
		first_set.visible = true
		first_set.play("first_set")
	else:
		jeeru.visible = true 
		jeeru.position = jeeru.original_position
		small_hing.visible = true 
		small_hing.position = small_hing.original_position
		spring_onion.visible = true
		spring_onion.position = spring_onion.original_position




func _on_ingredient_drag_ended(_drop_position: Vector2, ingredient_node: Node2D, _ingredient_name: String) -> void:
	if _is_overlapping(ingredient_node, pan):
		print("Ingredient dragged into pan: ", _ingredient_name)
		placed_order_first_set.append(_ingredient_name.strip_edges())
		print("Placed order after drag: ", placed_order_first_set)

		# Check if the order is correct so far
		if _check_order(placed_order_first_set, correct_order_first_set):
			print("Order is correct so far!")

			# Check if all ingredients are placed
			if placed_order_first_set.size() == correct_order_first_set.size():
				print("All ingredients placed in correct order")
				_hide_ingredients(_first_set_ingredients())
				_trigger_first_set_animation()
			else:
				print("Waiting for more ingredients...")
		else:
			print("Wrong order (order mismatch)")
			_trigger_wrong_order_animation()
			_reset_ingredients(placed_order_first_set, _first_set_ingredients())
			placed_order_first_set.clear()
	else:
		print("Ingredient dropped outside pan")
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
func _first_set_ingredients() -> Dictionary:
	return {
		"jeeru": jeeru,
		"small_hing": small_hing,
		"spring_onion": spring_onion,
	}


func _hide_ingredients(ingredients: Dictionary):
	for node in ingredients.values():
		node.visible = false


func _trigger_first_set_animation():
	print("Triggering first set animation")
	first_set_node.visible = true 
	first_set.visible = true       # Show visual node
	first_set.play("first_set")  
	bubbling.visible = false 
	bubbling.stop()


func _on_first_set_animation_finished():
	print("First set animation finished")
	first_set_node.visible = true      
	first_set.stop()
	_trigger_happy_ba_animation()
	
func _trigger_happy_ba_animation():
	print("happy ba triggered!")
	happy_ba_node.visible = true
	happy_ba.visible = true 
	happy_ba.play("happy_ba")

func _on_happy_ba_animation_finished():
	happy_ba.visible = false
	happy_ba_node.visible = false 
	happy_ba.stop()
	get_tree().change_scene_to_file("res://scenes/tomatoshak_2.tscn")

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
	get_tree().change_scene_to_file("res://scenes/book_5.tscn")
