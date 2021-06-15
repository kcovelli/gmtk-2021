extends Node2D

onready var globals = get_node("/root/Globals")

export(NodePath) var pb1_node_path = null setget set_pb1_path;
export(NodePath) var pb2_node_path = null setget set_pb2_path;

var pb1: PhysicsBody2D;
var pb2: PhysicsBody2D;

var strength: float = 1
var min_strength: float = 3

var shape: SegmentShape2D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pb1 = get_node(pb1_node_path)
	pb2 = get_node(pb2_node_path)
	print(pb1_node_path.get_name(pb1_node_path.get_name_count()-1), "  ", 
		  pb2_node_path.get_name(pb2_node_path.get_name_count()-1))
	
	# there might be a better way to instantiate a collider but whatever
	shape = SegmentShape2D.new()
	shape.a = pb1.position
	shape.b = pb2.position
	
	var collider = CollisionShape2D.new()
	collider.shape = shape
	
	var area = Area2D.new()
	area.add_child(collider)
	
	area.collision_layer = globals.COLLISION_LAYERS['lashings']
	area.collision_mask = 0
	
	add_child(area)
	
	pb1.start_lashing()
	pb2.start_lashing()

func _exit_tree():
	pb1.cancel_lashing()
	pb2.cancel_lashing()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if pb1 and pb2:
		update()
		var final_strength = max(min_strength, -pb1.position.distance_to(pb2.position) * strength)
		if pb1 is RigidBody2D:
			pb1.apply_central_impulse((pb2.position - pb1.position).normalized() * final_strength)
		if pb2 is RigidBody2D:
			pb2.apply_central_impulse((pb1.position - pb2.position).normalized() * final_strength)
		shape.a = pb1.position
		shape.b = pb2.position
	
func _draw():
	if pb1 and pb2:
		draw_line(pb1.position, pb2.position, Color(0, 100, 255))
		
func set_pb1_path(path):
	pb1_node_path = path
	if is_inside_tree():
		pb1 = get_node(pb1_node_path) 
	
func set_pb2_path(path):
	pb2_node_path = path
	if is_inside_tree():
		pb2 = get_node(pb2_node_path)
