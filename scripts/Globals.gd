extends Node

const COLLISION_LAYERS: Dictionary = {'lashings': 0x80000} # collision layer bitmasks

const CUT_MULTIPLE_LASHINGS: bool = true # whether you can cut multiple lashings at once

const LEVEL_LIST = [preload("res://levels/Level_0.tscn"),
					preload("res://levels/Level_1.tscn"),
					preload("res://levels/Level_2.tscn"),
					preload("res://levels/Level_3.tscn")]
