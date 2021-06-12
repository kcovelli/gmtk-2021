extends PhysicsBody2D

signal lashed_from
signal lashed_to

func _init():
	# Necessary so that _input_event gets invoked
	set_pickable(true)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				emit_signal("lashed_from", get_path())
			else:
				emit_signal("lashed_to", get_path())
			get_tree().set_input_as_handled()
