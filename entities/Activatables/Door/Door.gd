# TODO: should make an Activatable super class for door and button that handles state changes and inputs/outputs
extends StaticBody2D

# what physics layers to interact with (shouldn't be changed after init)
var DEFAULT_LAYERS = layers

# sprites for each state
var open_sprite = preload("res://entities/Activatables/Door/door_open.png")
var closed_sprite = preload("res://entities/Activatables/Door/tile_0150.png")

# how many input are currently enabled
var enabled_buttons = 0

# how many inputs are required to be enabled for door to change states
# currently initialized in Button._ready()
var required_buttons = 0

# current state of the door
var open = false setget set_open

# an input was enabled
func button_enabled():
	print('button enabled signal recieved')
	enabled_buttons += 1
	if enabled_buttons == required_buttons:
		set_open(true)
		
# an input was disabled	
func button_disabled():
	print('button disabled signal recieved')
	enabled_buttons -= 1
	if enabled_buttons < required_buttons:
		set_open(false)
	
# change state of door
func set_open(state: bool):
	if state == open:
		return
	open = state
	
	# change sprite and physics layers
	if open:
		$Sprite.texture = open_sprite
		layers = 0
	else:
		$Sprite.texture = closed_sprite
		layers = DEFAULT_LAYERS
