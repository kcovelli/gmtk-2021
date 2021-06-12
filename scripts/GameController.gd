extends Node2D

onready var globals = get_node("/root/Globals")

var drag_mode: int = 0 # 0 while not dragging, 1 for create, 2 for cut
var drag_start: Vector2
var lash_create_colour: Color = Color(0, 255, 0)
var lash_cut_colour: Color = Color(255, 0, 0)

const lashing_scene: PackedScene = preload("res://scenes/Lashing.tscn")
var lashed_from: PhysicsBody2D = null # Keeps track of prev. lashed object

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
			if drag_mode == 2:
				lash_cut(drag_start, event.position)
			drag_mode = 0
			update() # calls _draw()
			
	elif event.is_action_pressed("slow_time"):
		Engine.time_scale = 0.2
	elif event.is_action_released("slow_time"):
		Engine.time_scale = 1

func _draw():
	if drag_mode > 0:
		draw_line(drag_start, get_global_mouse_position(), lash_create_colour if drag_mode == 1 else lash_cut_colour)
		
func _process(_delta):
	if drag_mode > 0:
		if drag_mode == 1 and lashed_from: # draw lash create line starting from selected object
			drag_start = lashed_from.position
		update()

func lash_cut(start: Vector2, end: Vector2):
	# do raycast to see if cutting line intersects a lash
	var space_state = get_world_2d().direct_space_state
	var collision = null
	var found_objs = []
	
	# keep doing raycasts until we don't intersect any lashes. intersect_ray() only returns the first collision
	# so we have to do this multiple times if we want to cut more than one lash at a time. 
	# there's probably a better way to do this but whatever
	while true:
		collision = space_state.intersect_ray(start, end, found_objs, globals.COLLISION_LAYERS['lashings'],  true, true)
		if collision.size() > 0:
			found_objs.append(collision['collider'])
			get_tree().queue_delete(collision['collider'].get_parent())
		else:
			break
		
		if !globals.CUT_MULTIPLE_LASHINGS:
			break
	
# signal handler for mouse click on object
func handle_lashed_from(path):
	lashed_from = get_node(path)
	drag_mode = 1

# signal handler for mouse release on object
func handle_lashed_to(path):
	if lashed_from == null:
		return
	
	var from_path = lashed_from.get_path()
	if from_path != path:
		var lashing = lashing_scene.instance()
		lashing.set_pb1_path(from_path)
		lashing.set_pb2_path(path)
		add_child(lashing)
	
	lashed_from = null
