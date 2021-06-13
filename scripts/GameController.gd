extends Node2D

var globals = preload("res://scripts/Globals.gd")
var curr_level_num = 0 setget set_curr_level_num
var curr_level = globals.LEVEL_LIST[curr_level_num].instance() 

var drag_mode: int = 0 # 0 while not dragging, 1 for create, 2 for cut
var drag_start: Vector2
var lash_create_colour: Color = Color(0, 255, 0)
var lash_cut_colour: Color = Color(255, 0, 0)

const lashing_scene: PackedScene = preload("res://scenes/Lashing.tscn")
var lashed_from: PhysicsBody2D = null # Keeps track of prev. lashed object

##### GODOT FUNCTIONS #####

func _ready():
	add_child(curr_level)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		handle_mouse_button_event(event)
	elif event.is_action_pressed("slow_time"):
		Engine.time_scale = 0.2
		get_node("Overlay/Sprite").visible = true
	elif event.is_action_released("slow_time"):
		Engine.time_scale = 1
		get_node("Overlay/Sprite").visible = false
	elif event.is_action_pressed("next_level"):
		print('going to next level')
		next_level()
	elif event.is_action_pressed("prev_level"):
		print('going to prev level')
		set_curr_level_num(curr_level_num - 1)

# draw lashing cut/create line
func _draw():
	if drag_mode > 0:
		draw_line(drag_start, get_global_mouse_position(), lash_create_colour if drag_mode == 1 else lash_cut_colour)
		
func _process(_delta):
	if drag_mode > 0:
		if drag_mode == 1 and lashed_from: # draw lash create line starting from selected object
			drag_start = lashed_from.position
		update()
		
##### INPUT AND SIGNAL HANDLERS #####

# mouse click on LashableObject
func handle_lashed_from(path):
	lashed_from = get_node(path)
	drag_mode = 1

# mouse release on LashableObject
func handle_lashed_to(path):
	if lashed_from == null:
		return
	
	var from_path = lashed_from.get_path()
	if from_path != path:
		var lashing = lashing_scene.instance()
		lashing.set_pb1_path(from_path)
		lashing.set_pb2_path(path)
		get_child(1).add_child(lashing) # level scene should always be the only child of Main
	
	lashed_from = null

func next_level():
	set_curr_level_num(curr_level_num + 1)

func handle_mouse_button_event(event):
	if event.pressed:
			if event.button_index == BUTTON_RIGHT:
				drag_mode = 2
			drag_start = screen_coords_to_world(event.position)
	else:
		if event.button_index == BUTTON_LEFT and lashed_from != null:
			# Reset lashed_from since mouse was released on a non-lashable
			# object (otherwise this mouse event would have been handled)
			lashed_from.cancel_lashing()
			lashed_from = null
		if drag_mode == 2:
			lash_cut(drag_start, screen_coords_to_world(event.position))
		drag_mode = 0
		update() # calls _draw()

##### HELPERS #####
func set_curr_level_num(lvl: int):
	if lvl > globals.LEVEL_LIST.size()-1 or lvl < 0:
		print('invalid level number')
		return
	
	# TODO: fade to black before switching
	if lvl != curr_level_num:		
		curr_level_num = lvl
		get_tree().queue_delete(curr_level)
		curr_level = globals.LEVEL_LIST[curr_level_num].instance()
		call_deferred('add_child', curr_level)
	else:
		print('tried to set level to the current level. TODO: add a retry level function')
		
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

func screen_coords_to_world(screen_vec: Vector2) -> Vector2:
	return screen_vec - get_canvas_transform().origin
	
func world_coords_to_screen(world_vec: Vector2) -> Vector2:
	return world_vec + get_canvas_transform().origin
