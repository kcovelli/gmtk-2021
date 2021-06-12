extends PhysicsBody2D

# We assume there is always a single node that's orchestrating lashings, and it
# doesn't change during runtime
const HANDLER_PATH = "/root/Main"

signal lashed_from
signal lashed_to

func _init():
	# Necessary so that _input_event gets invoked
	set_pickable(true)

func _enter_tree():
	var lash_handler = get_node(HANDLER_PATH)
	connect("lashed_from", lash_handler, "handle_lashed_from")
	connect("lashed_to", lash_handler, "handle_lashed_to")

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				emit_signal("lashed_from", get_path())
			else:
				emit_signal("lashed_to", get_path())
			get_tree().set_input_as_handled()
