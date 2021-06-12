extends Node2D

var dragging: bool = false
var drag_start: Vector2

const lashing_scene: PackedScene = preload("res://scenes/Lashing.tscn")
var lashed_from: NodePath # Keeps track of prev. object that was lashed from

func _ready():
	$Box1.connect("lashed_from", self, "handle_lashed_from")
	$Box1.connect("lashed_to", self, "handle_lashed_to")
	$Box2.connect("lashed_from", self, "handle_lashed_from")
	$Box2.connect("lashed_to", self, "handle_lashed_to")
	$Box3.connect("lashed_from", self, "handle_lashed_from")
	$Box3.connect("lashed_to", self, "handle_lashed_to")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = event.position
		else:
			dragging = false
			update()
			
		print(event.position, dragging)
	

func _draw():
	if dragging:
		draw_line(drag_start, get_global_mouse_position(), Color(255, 0, 0))
		
func _process(delta):
	if dragging:
		update()

func handle_lashed_from(path):
	lashed_from = path

func handle_lashed_to(path):
	if lashed_from == "":
		return
	
	if lashed_from != path:
		var lashing = lashing_scene.instance()
		lashing.pb1_node_path = lashed_from
		lashing.pb2_node_path = path
		add_child(lashing)
	
	lashed_from = ""
