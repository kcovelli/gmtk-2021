extends PhysicsBody2D

# We assume there is always a single node that's orchestrating lashings, and it
# doesn't change during runtime
const HANDLER_PATH: String = "/root/Main"
const GLOW_SCENE: PackedScene = preload("res://scenes/Glow.tscn")

signal lashed_from
signal lashed_to

var is_hovered: bool = false
var glow: Node = null

func _init():
	# Necessary so that mouse signals get emitted
	set_pickable(true)
	connect("mouse_entered", self, "handle_mouse_entered")
	connect("mouse_exited", self, "handle_mouse_exited")

func _enter_tree():
	var lash_handler = get_node(HANDLER_PATH)
	connect("lashed_from", lash_handler, "handle_lashed_from")
	connect("lashed_to", lash_handler, "handle_lashed_to")

func _input(event):
	if not is_hovered:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				emit_signal("lashed_from", get_path())
				# Swallow the mouse press
				get_tree().set_input_as_handled()
			else:
				emit_signal("lashed_to", get_path())
				# Don't swallow the mouse press, since GameController needs
				# to end the drag.

func start_glow():
	glow = GLOW_SCENE.instance()
	
	var shape = $CollisionShape2D.shape
	if shape is RectangleShape2D:
		glow.shape = ParticlesMaterial.EMISSION_SHAPE_BOX
		glow.extents = shape.extents
	elif shape is CircleShape2D:
		glow.shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
		glow.radius = shape.radius
	else:
		assert(false, "Yell at Nadav")
	
	add_child(glow)

func stop_glow():
	remove_child(glow)

func handle_mouse_entered():
	is_hovered = true
	start_glow()

func handle_mouse_exited():
	is_hovered = false
	stop_glow()
