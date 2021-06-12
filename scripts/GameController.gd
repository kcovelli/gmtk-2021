extends Node2D

var drag_mode: int = 0 # 0 while not dragging, 1 for create, 2 for cut
var drag_start: Vector2
var lash_create_colour: Color = Color(0, 255, 0)
var lash_cut_colour: Color = Color(255, 0, 0)

const lashing_scene: PackedScene = preload("res://scenes/Lashing.tscn")
var lashed_from: PhysicsBody2D = null # Keeps track of prev. lashed object

func _ready():
	$Box1.connect("lashed_from", self, "handle_lashed_from")
	$Box1.connect("lashed_to", self, "handle_lashed_to")
	$Box2.connect("lashed_from", self, "handle_lashed_from")
	$Box2.connect("lashed_to", self, "handle_lashed_to")
	$Box3.connect("lashed_from", self, "handle_lashed_from")
	$Box3.connect("lashed_to", self, "handle_lashed_to")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		
		if event.pressed:
			if event.button_index == BUTTON_RIGHT:
				drag_mode = 2
			elif event.button_index == BUTTON_LEFT:
				# Reset lashed_from since mouse was released on a non-lashable
				# object (otherwise this mouse event would have been handled)
				lashed_from = null
			drag_start = event.position
		else:
			drag_mode = 0
			update() # calls _draw()
			
		print(event.position, drag_mode)
	

func _draw():
	if drag_mode > 0:
		draw_line(drag_start, get_global_mouse_position(), lash_create_colour if drag_mode == 1 else lash_cut_colour)
		
func _process(delta):
	if drag_mode > 0:
		if drag_mode == 1 and lashed_from:
			drag_start = lashed_from.position
		update()

func handle_lashed_from(path):
	lashed_from = get_node(path)
	drag_mode = 1

func handle_lashed_to(path):
	if lashed_from == null:
		return
	
	var from_path = lashed_from.get_path()
	if from_path != path:
		var lashing = lashing_scene.instance()
		lashing.pb1_node_path = from_path
		lashing.pb2_node_path = path
		add_child(lashing)
	
	lashed_from = null
	
