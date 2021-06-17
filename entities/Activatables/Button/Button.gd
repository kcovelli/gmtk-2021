extends Node2D

# signals for button events
signal trigger_button_enabled;
signal trigger_button_disabled;

# list of all connected activatable objects 
# TODO: rename
export var connected_doors = []

# current state of button
var state = false setget set_state

# number of rigidbodies currently intersecting the button
var num_bodies = 0

# sprites for each state
var active_sprite = preload("res://entities/Activatables/Button/tile_0128.png")
var inactive_sprite = preload("res://entities/Activatables/Button/tile_0129.png")

# connect each door to the button's signals
func _ready():
	for door_node_path in connected_doors:
		var door = get_node(door_node_path)
		connect("trigger_button_enabled", door, "button_enabled")
		connect("trigger_button_disabled", door, "button_disabled")
		door.required_buttons += 1
		print(door)
		
# change state of button
func set_state(s: bool):
	if state == s: # do nothing if already in desired state
		return
	state = s
	
	# change sprite texture and emit signals
	if state:
		$Sprite.texture = active_sprite
		emit_signal("trigger_button_enabled")
		print('button enabled signal sent')
	else:
		$Sprite.texture = inactive_sprite
		emit_signal("trigger_button_disabled")
		print('button disabled signal sent')

# event handlers
func _on_Area2D_body_entered(_body):
	num_bodies += 1
	set_state(true)
func _on_Area2D_body_exited(_body):
	num_bodies -= 1
	if num_bodies == 0:
		set_state(false)
