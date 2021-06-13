extends Node2D

signal trigger_button_enabled;
signal trigger_button_disabled;

export var connected_doors = []

var state = false setget set_state
var num_bodies = 0

var active_sprite = preload("res://assets/objects/tile_0128.png")
var inactive_sprite = preload("res://assets/objects/tile_0129.png")

func _ready():
	for door_node_path in connected_doors:
		var door = get_node(door_node_path)
		connect("trigger_button_enabled", door, "button_enabled")
		connect("trigger_button_disabled", door, "button_disabled")
		door.required_buttons += 1
		print(door)

func _on_Area2D_body_entered(_body):
	num_bodies += 1
	set_state(true)

func _on_Area2D_body_exited(_body):
	num_bodies -= 1
	if num_bodies == 0:
		set_state(false)

func set_state(s: bool):
	if state == s:
		return
	state = s
	if state:
		$Sprite.texture = active_sprite
		emit_signal("trigger_button_enabled")
		print('button enabled signal sent')
	else:
		$Sprite.texture = inactive_sprite
		emit_signal("trigger_button_disabled")
		print('button disabled signal sent')
