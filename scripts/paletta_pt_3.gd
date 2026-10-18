extends Node2D

@onready var is_dragging = false
@onready var drag_offset = Vector2.ZERO

#items that hold the draggables 
@onready var pan = $Pan

#draggable ingredients: 
@onready var oil = $oil
@onready var battered_veg = $BatteredVeg 

# animations 
@onready var gas_and_fire = $gas_and_fire/gas_and_fire
@onready var spoon = $spoon/spoon
@onready var bubbling = $bubbling/bubbling
@onready var fried_paletta = $fried_paletta/fried_paletta 

@onready var swaad = $swaad/swaad
@onready var swaadsfx = $swaadsfx
@onready var cooking = $cooking

func _ready():
	swaadsfx.stop()
	cooking.play()
	
	for ingredient in [oil, battered_veg]:
		ingredient.original_position = ingredient.position
	
	
	
	set_node_interactive(battered_veg, false)
	set_node_interactive(oil, true)
	
	# animations are initially hidden 
	gas_and_fire.visible = true 
	gas_and_fire.play("gas_and_fire")
	gas_and_fire.position = Vector2(773, 248)
	
	spoon.visible = false 
	bubbling.visible = false 
	fried_paletta.visible = false
	
	swaad.visible = false
	#items that hold the draggables
	pan.visible = true
	

	oil.connect("drag_ended", Callable(self, "_on_oil_drag_ended"))
	battered_veg.connect("drag_ended", Callable(self, "_on_battered_veg_drag_ended"))

	_connect_animation_signals() 
	
	
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
	var spoon_callback = Callable(self, "_on_spoon_animation_finished")
	if spoon.is_connected("animation_finished", spoon_callback):
		spoon.disconnect("animation_finished", spoon_callback)
	spoon.connect("animation_finished", spoon_callback) 
	
	var gas_and_fire_callback = Callable(self, "_on_gas_and_fire_animation_finished")
	if gas_and_fire.is_connected("animation_finished", gas_and_fire_callback):
		gas_and_fire.disconnect("animation_finished", gas_and_fire_callback)
	gas_and_fire.connect("animation_finished", gas_and_fire_callback)
	
	var bubbling_callback = Callable(self, "_on_bubbling_animation_finished")
	if bubbling.is_connected("animation_finished", bubbling_callback):
		bubbling.disconnect("animation_finished", bubbling_callback)
	bubbling.connect("animation_finished", bubbling_callback) 

	var fried_paletta_callback = Callable(self, "_on_fried_paletta_animation_finished")
	if fried_paletta.is_connected("animation_finished", fried_paletta_callback):
		fried_paletta.disconnect("animation_finished", fried_paletta_callback)
	fried_paletta.connect("animation_finished", fried_paletta_callback) 

	var swaad_callback = Callable(self, "_on_swaad_animation_finished")
	if swaad.is_connected("animation_finished", swaad_callback):
		swaad.disconnect("animation_finished", swaad_callback)
	swaad.connect("animation_finished", swaad_callback)


func _on_oil_drag_ended(_drop_position: Vector2):
	if _is_overlapping(oil, pan):
		print("oil dragged")
		oil.visible = false
		spoon.visible = true
		spoon.play("spoon")
		spoon.position = Vector2(858, 100)
		set_node_interactive(oil, false)
		set_node_interactive(battered_veg, true)
	else:
		print("wrong")
		oil.position = oil.original_position
		oil.visible = true
		set_node_interactive(oil, true)
		set_node_interactive(battered_veg, false)
		
func _on_battered_veg_drag_ended(_drop_position: Vector2):
	if _is_overlapping(battered_veg, pan):
		print("oil dragged")
		battered_veg.visible = false
		fried_paletta.visible = true
		fried_paletta.play("fried_paletta")
		fried_paletta.position = Vector2(872.5, 170)
		set_node_interactive(oil, false)
		set_node_interactive(battered_veg, false)
	else:
		print("wrong")
		battered_veg.position = battered_veg.original_position
		battered_veg.visible = true
		set_node_interactive(oil, false)
		set_node_interactive(battered_veg, true)


func _on_spoon_animation_finished():
	spoon.stop()
	spoon.visible = false
	bubbling.play("bubbling")
	bubbling.visible = true 
	bubbling.position = Vector2(866, 169)


func _on_fried_paletta_animation_finished():
	fried_paletta.stop()
	_trigger_swaad_animation()

func _trigger_swaad_animation():
	print("swaad!")
	swaad.visible = true 
	swaad.play("swaad")
	swaadsfx.play()
	cooking.stop()

func _on_swaad_animation_finished():
	get_tree().change_scene_to_file("res://scenes/ending_aubergine.tscn")
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
	get_tree().change_scene_to_file("res://scenes/book_1.tscn")
