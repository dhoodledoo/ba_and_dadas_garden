extends Sprite2D

var _animation_player = "pour"
#region Alert system... 

func _on_child_entered_tree(child: AnimatedSprite2D): 
	if child.is_in_group("pan"):
		_animation_player.play()
