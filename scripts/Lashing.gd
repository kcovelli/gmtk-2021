extends Node

export(NodePath) var pb1_node_path;
export(NodePath) var pb2_node_path;

var pb1: RigidBody2D;
var pb2: RigidBody2D;

var strength: float = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pb1 = get_node(pb1_node_path)
	pb2 = get_node(pb2_node_path)
	print(pb1, pb2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pb1.apply_central_impulse(pb1.position.direction_to(pb2.position) * strength)
	pb2.apply_central_impulse(pb2.position.direction_to(pb1.position) * strength)
