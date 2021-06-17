extends Node

# collision layer bitmasks for instantiating scenes on a specific layer
const COLLISION_LAYERS: Dictionary = {'lashings': 0x80000}

# whether you can cut multiple lashings at once
const CUT_MULTIPLE_LASHINGS := true 

# whether to draw normals of current collisions w/ player
const DRAW_DEBUG_NORMS := false

# whether lashing apply a constant force, or are stronger the further apart the objects are
const LASHINGS_CONSTANT_FORCE := true

# maximum distance two objects can be lashed
const LASHING_MAX_DISTANCE := -1

# list of level scenes and the order to load them in
const LEVEL_LIST = [preload("res://levels/test_level.tscn"),
					preload("res://levels/Level_0.tscn"),
					preload("res://levels/Level_1.tscn"),
					preload("res://levels/Level_2.tscn"),
					preload("res://levels/Level_3.tscn")]

# helper to test whether two vectors are approximately equal
func vec_equal_approx(v1: Vector2, v2: Vector2):
	return is_equal_approx(v1[0], v2[0]) and is_equal_approx(v1[1], v2[1])
