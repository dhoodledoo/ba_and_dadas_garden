extends Sprite2D

signal drag_ended

var is_dragging = false
var drag_offset = Vector2.ZERO
var original_position = Vector2.ZERO
var mouse_offset # on click
var delay = 10

func _ready():
	original_position = position

		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				is_dragging = true
				drag_offset = position - event.position
				get_viewport().set_input_as_handled()
			elif not event.pressed and is_dragging:
				is_dragging = false
				emit_signal("drag_ended", position)
	elif event is InputEventMouseMotion and is_dragging:
		global_position = event.position + drag_offset
