extends Node2D



@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO


@onready var pan = $pan

# Animations 
@onready var gas_and_fire = $gasandfire/AnimatedSprite2D
@onready var first_set_loop_node = $first_set_loop
@onready var first_set_loop = $first_set_loop/first_set_loop
@onready var second_set_node = $second_set
@onready var second_set = $second_set/second_set

@onready var swaad = $swaad/swaad
@onready var swaadsfx = $swaadsfx
# Wrong order nodes
@onready var wrong_order_node = $Wrong_Order
@onready var wrong_order_anim = $Wrong_Order/AnimationPlayer
@onready var wrong_order_sfx = $wrongordersfx

@onready var cooking = $cooking

#ingredients 
@onready var small_garlic = $small_garlic
@onready var green_chilli = $green_chilli
@onready var small_red_chilli = $small_red_chilli
@onready var small_tumeric = $small_tumeric
@onready var small_dhana_jeeru = $small_dhana_jeeru
@onready var small_salt = $small_salt
@onready var tomato = $tomato
@onready var small_ghor = $small_ghor

#labels
@onready var salt_label = $salt_
@onready var dhanajeeru_label = $dhanajeeru_
@onready var turmeric_label = $turmeric_
@onready var redchilli_label = $redchilli_
@onready var ghor_label = $ghor_

var correct_order_main_ingredients = [
	"small_garlic",
	"green_chilli",
	"small_red_chilli",
	"small_tumeric",
	"small_dhana_jeeru",
	"small_salt",
	"tomato",
	"small_ghor"
]
var placed_order_main_ingredients = []

func _ready():
	wrong_order_sfx.stop()
	swaadsfx.stop()
	cooking.play()
	for ingredient in [
		small_garlic, green_chilli, small_red_chilli, small_tumeric,
		small_dhana_jeeru, small_salt, tomato, small_ghor]:
		ingredient.original_position = ingredient.position

	

	gas_and_fire.visible = true
	gas_and_fire.play("gas_and_fire")
	first_set_loop.visible = true
	first_set_loop.play("first_set_loop")
	# animations are initally hidden 
	second_set.visible = false
	wrong_order_node.visible = false
	swaad.visible = false
	# Connected ingredient drag_ended signals with correct argument order
	_connect_ingredient_signals() 
	
	
func _connect_ingredient_signals():
	# Second set ingredients
	small_garlic.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_garlic, "small_garlic"))
	green_chilli.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(green_chilli, "green_chilli"))
	small_red_chilli.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_red_chilli, "small_red_chilli"))
	small_tumeric.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_tumeric, "small_tumeric"))
	small_dhana_jeeru.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_dhana_jeeru, "small_dhana_jeeru"))
	small_salt.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_salt, "small_salt"))
	tomato.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(tomato, "tomato"))
	small_ghor.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(small_ghor, "small_ghor")) 
	
func _connect_animation_signals():
	var first_set_loop_callback = Callable(self, "_on_first_set_loop_animation_finished")
	if first_set_loop.is_connected("animation_finished", first_set_loop_callback):
		first_set_loop.disconnect("animation_finished", first_set_loop_callback)
	first_set_loop.connect("animation_finished", first_set_loop_callback)

	var second_set_callback = Callable(self, "_on_second_set_animation_finished")
	if second_set.is_connected("animation_finished", second_set_callback):
		second_set.disconnect("animation_finished", second_set_callback)
	second_set.connect("animation_finished", second_set_callback)

	var wrong_order_callback = Callable(self, "_on_wrong_order_animation_finished")
	if wrong_order_anim.is_connected("animation_finished", wrong_order_callback):
		wrong_order_anim.disconnect("animation_finished", wrong_order_callback)
	wrong_order_anim.connect("animation_finished", wrong_order_callback)

	var swaad_callback = Callable(self, "_on_swaad_animation_finished")
	if swaad.is_connected("animation_finished", swaad_callback):
		swaad.disconnect("animation_finished", swaad_callback)
	swaad.connect("animation_finished", swaad_callback)
	
func _on_first_set_loop_animation_started():
	if first_set_loop.animation == "first_set_loop":
		print("first set loop animation started, second set phase enabled")
		first_set_loop_node.visible = true
		first_set_loop.visible = true
		first_set_loop.play("first_set_loop")


func _on_ingredient_drag_ended(_drop_position: Vector2, ingredient_node: Node2D, _ingredient_name: String) -> void:
	if _is_overlapping(ingredient_node, pan):
		print("Ingredient dragged into pan: ", _ingredient_name)
		placed_order_main_ingredients.append(_ingredient_name.strip_edges())
		print("Placed order after drag: ", placed_order_main_ingredients)

		# Check if the order is correct so far
		if _check_order(placed_order_main_ingredients, correct_order_main_ingredients):
			print("Order is correct so far!")

			# Check if all ingredients are placed
			if placed_order_main_ingredients.size() == correct_order_main_ingredients.size():
				print("All ingredients placed in correct order")
				_hide_ingredients(_main_ingredients())
				_trigger_second_set_animation()
			else:
				print("Waiting for more ingredients...")
		else:
			print("Wrong order (order mismatch)")
			_trigger_wrong_order_animation()
			_reset_ingredients(placed_order_main_ingredients, _main_ingredients())
			placed_order_main_ingredients.clear()
	else:
		print("Ingredient dropped outside pan")
		ingredient_node.position = ingredient_node.original_position



# Reset ingredients to their original positions
func _reset_ingredients(placed: Array, ingredients: Dictionary) -> void:
	print("Resetting ingredients: ", placed)
	for ingredient_name in placed:
		var node = ingredients.get(ingredient_name, null)
		if node:
			node.position = node.original_position

# Hide all ingredients
func _hide_ingredients(ingredients: Dictionary) -> void:
	for node in ingredients.values():
		node.visible = false

# Get the dictionary of ingredients
func _main_ingredients() -> Dictionary:
	return {
		"small_garlic": small_garlic,
		"green_chilli": green_chilli,
		"small_red_chilli": small_red_chilli,
		"small_tumeric": small_tumeric,
		"small_dhana_jeeru": small_dhana_jeeru,
		"small_salt": small_salt,
		"tomato": tomato,
		"small_ghor": small_ghor,
	}

# Check if the placed order matches the correct order
func _check_order(placed: Array, correct: Array) -> bool:
	# Check if the placed array is larger than the correct array
	if placed.size() > correct.size():
		print("Placed array is larger than correct array!")
		return false

	# Check if the order matches up to the current size
	for i in range(placed.size()):
		if placed[i] != correct[i]:
			print("Mismatch at index ", i, ": ", placed[i], " != ", correct[i])
			return false

	return true

func _on_first_set_loop_animation_finished():
	if correct_order_main_ingredients == placed_order_main_ingredients:
		print("First set loop animation finished")
		first_set_loop_node.visible = false
		first_set_loop.stop()
		second_set_node.visible = true 
		second_set.visible = true
		second_set.play("second_set")
		second_set.position = Vector2(682.5, 137)


func _trigger_second_set_animation():
	print("Triggering Second Set Animation")  # Debug print
	second_set.visible = true
	second_set.play("second_set")
	second_set.position = Vector2(682.5, 137)
	first_set_loop.visible = false
	first_set_loop.stop()


func _on_second_set_animation_finished():
	print("Second set animation finished")
	second_set_node.visible = true
	second_set.visible = true
	second_set.stop()
	_trigger_swaad_animation()


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
	get_tree().change_scene_to_file("res://scenes/ending_tomato.tscn")
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
	get_tree().change_scene_to_file("res://scenes/book_5.tscn")
	
	
	
	
