extends Node2D

var dragging: bool = false
var drag_start: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
