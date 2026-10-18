extends Node2D

@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO

# Items that hold the draggables
@onready var bowl = $EmptyBowl

# Extra utensils and ingredients
@onready var oil = $oil
@onready var chickpea_flour = $ChickpeaFlour
@onready var small_ginger = $SmallGinger
@onready var small_garlic = $SmallGarlic
@onready var small_salt = $SmallSalt
@onready var small_tumeric = $SmallTumeric
@onready var small_red_chilli = $SmallRedChilli
@onready var green_chilli = $GreenChilli
@onready var small_garam_masala = $SmallGaramMasala
@onready var small_dhana_jeeru = $SmallDhanaJeeru
@onready var water = $Water
@onready var veg = $Veg

@onready var batter = $Batter

# Animations
@onready var spoon = $spoon/spoon
@onready var battered_veg = $battered_veg/battered_veg

@onready var wrong_order_node = $Wrong_Order
@onready var wrong_order_anim = $Wrong_Order/AnimationPlayer
@onready var wrong_order_sfx = $wrongordersfx


var correct_order_first_set = [
	"chickpea_flour", "water", "small_salt", "small_tumeric",
	"small_red_chilli", "green_chilli", "small_garam_masala", "small_dhana_jeeru",
	"small_ginger", "small_garlic", "oil"
]

var correct_order_second_set = ["veg"]

# Tracking placed ingredients by name
var placed_order_first_set = []
var placed_order_second_set = []

var in_first_set_phase = true
var in_second_set_phase = false


var first_set_ingredients_dict = {}
var second_set_ingredients_dict = {}


func _ready():
	wrong_order_sfx.stop()
	
	# Initialize ingredient dictionaries
	first_set_ingredients_dict = {
		"chickpea_flour": chickpea_flour,
		"small_ginger": small_ginger,
		"small_garlic": small_garlic,
		"small_salt": small_salt,
		"small_tumeric": small_tumeric,
		"small_red_chilli": small_red_chilli,
		"green_chilli": green_chilli,
		"small_garam_masala": small_garam_masala,
		"small_dhana_jeeru": small_dhana_jeeru,
		"water": water,
		"oil": oil,
	}

	second_set_ingredients_dict = {
		"veg": veg,
	}

	# Store original positions for reset
	for ingredient in first_set_ingredients_dict.values():
		ingredient.original_position = ingredient.position
	for ingredient in second_set_ingredients_dict.values():
		ingredient.original_position = ingredient.position

	
	
	# Hide animations and batter initially
	spoon.visible = false
	battered_veg.visible = false
	wrong_order_node.visible = false
	batter.visible = false
	bowl.visible = true

	# Connect drag ended signals using generic handler with bound parameters
	for ingredient_name in first_set_ingredients_dict.keys():
		var node = first_set_ingredients_dict[ingredient_name]
		node.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(node, ingredient_name))

	for ingredient_name in second_set_ingredients_dict.keys():
		var node = second_set_ingredients_dict[ingredient_name]
		node.connect("drag_ended", Callable(self, "_on_ingredient_drag_ended").bind(node, ingredient_name))

	_connect_animation_signals()

func _connect_animation_signals():
	var spoon_callback = Callable(self, "_on_spoon_animation_finished")
	if spoon.is_connected("animation_finished", spoon_callback):
		spoon.disconnect("animation_finished", spoon_callback)
	spoon.connect("animation_finished", spoon_callback)

	var wrong_order_callback = Callable(self, "_on_wrong_order_animation_finished")
	if wrong_order_anim.is_connected("animation_finished", wrong_order_callback):
		wrong_order_anim.disconnect("animation_finished", wrong_order_callback)
	wrong_order_anim.connect("animation_finished", wrong_order_callback)

	var battered_veg_callback = Callable(self, "_on_battered_veg_animation_finished")
	if battered_veg.is_connected("animation_finished", battered_veg_callback):
		battered_veg.disconnect("animation_finished", battered_veg_callback)
	battered_veg.connect("animation_finished", battered_veg_callback)

# Generic drag ended handler for all ingredients
func _on_ingredient_drag_ended(_drop_position: Vector2, ingredient_node: Node2D, ingredient_name: String):
	if _is_overlapping(ingredient_node, bowl):
		if in_first_set_phase:
			# Reject second set ingredients in first phase
			if ingredient_name in second_set_ingredients_dict.keys():
				print("Second set ingredient not allowed yet:", ingredient_name)
				ingredient_node.position = ingredient_node.original_position
				_trigger_wrong_order_animation()
				return

			if ingredient_name not in placed_order_first_set:
				placed_order_first_set.append(ingredient_name)
				print("Placed first set ingredient:", ingredient_name)

			if _check_order(placed_order_first_set, correct_order_first_set):
				if placed_order_first_set.size() == correct_order_first_set.size():
					_trigger_spoon_animation()
			else:
				print("Wrong order in first set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_first_set, first_set_ingredients_dict)
				placed_order_first_set.clear()

		elif in_second_set_phase:
			if ingredient_name not in placed_order_second_set:
				placed_order_second_set.append(ingredient_name)
				print("Placed second set ingredient:", ingredient_name)

			if _check_order(placed_order_second_set, correct_order_second_set):
				if placed_order_second_set.size() == correct_order_second_set.size():
					_hide_ingredients(second_set_ingredients_dict)
					_trigger_battered_veg_animation()
					batter.visible = false
					
			else:
				print("Wrong order in second set")
				_trigger_wrong_order_animation()
				_reset_ingredients(placed_order_second_set, second_set_ingredients_dict)
				placed_order_second_set.clear()
	else:
		# Reset position if dropped outside bowl
		ingredient_node.position = ingredient_node.original_position

func _check_order(placed: Array, correct: Array) -> bool:
	for i in range(placed.size()):
		if placed[i] != correct[i]:
			return false
	return true

func _reset_ingredients(placed: Array, ingredients: Dictionary):
	for ingredient_name in placed:
		var node = ingredients.get(ingredient_name, null)
		if node:
			node.visible = true
			node.position = node.original_position

func _hide_ingredients(ingredients: Dictionary):
	for node in ingredients.values():
		node.visible = false

func _start_second_set_phase():
	in_first_set_phase = false
	in_second_set_phase = true
	batter.visible = true
	print("Second set phase started")


func _trigger_battered_veg_animation():
	print("Battered veg animation triggered")
	battered_veg.position = Vector2(581.5, 190)
	battered_veg.visible = true
	battered_veg.play("battered_veg")
	# Start a timer before changing scene
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1  # seconds, adjust as needed
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_battered_veg_timer_timeout"))
	timer.start()

func _on_battered_veg_timer_timeout():
	battered_veg.stop()
	battered_veg.visible = false
	get_tree().change_scene_to_file("res://scenes/paletta_pt_3.tscn")
	
func _on_battered_veg_animation_finished():
	print("Battered veg animation finished")
	battered_veg.visible = false
	battered_veg.stop()

func _trigger_wrong_order_animation():
	print("Wrong order animation triggered")
	wrong_order_node.visible = true
	wrong_order_anim.play("wrong_order")
	wrong_order_sfx.play()

func _on_wrong_order_animation_finished():
	print("Wrong order animation finished")
	wrong_order_anim.stop()
	wrong_order_node.visible = false
	wrong_order_sfx.stop()

func _trigger_spoon_animation():
	print("spoon animation triggered")
	spoon.visible = true 
	spoon.play("spoon")
	spoon.position = Vector2(612, 174)
	oil.visible = false
	

func _on_spoon_animation_finished():
	if spoon.animation == "spoon":
		spoon.visible = false
		spoon.stop()
		is_dragging = false
		drag_offset = position + bowl.position
		batter.visible = true
		_start_second_set_phase()
		_hide_ingredients(first_set_ingredients_dict)
	else:
		spoon.stop()
		spoon.visible = false


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
