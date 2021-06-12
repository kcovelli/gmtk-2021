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

func _draw():
	if drag_mode > 0:
		draw_line(drag_start, get_global_mouse_position(), lash_create_colour if drag_mode == 1 else lash_cut_colour)
		
func _process(delta):
	if drag_mode > 0:
		if drag_mode == 1 and lashed_from:
			drag_start = lashed_from.position
		update()

func lash_cut(start: Vector2, end: Vector2):
	var space_state = get_world_2d().direct_space_state
	
	var collision = space_state.intersect_ray(start, end, [], globals.collision_layers['lashings'],  true, true)
	var lash_collider: Area2D = collision['collider']
	get_tree().queue_delete(lash_collider.get_parent())
	
	
	

func handle_lashed_from(path):
	lashed_from = get_node(path)
	drag_mode = 1

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
