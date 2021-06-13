extends StaticBody2D

var DEFAULT_LAYERS = layers

var open_sprite = preload("res://assets/objects/door_open.png")
var closed_sprite = preload("res://assets/objects/tile_0150.png")

var enabled_buttons = 0
var required_buttons = 0

var open = false setget set_open
	
func button_enabled():
	print('button enabled signal recieved')
	enabled_buttons += 1
	if enabled_buttons == required_buttons:
		set_open(true)
	
func button_disabled():
	print('button disabled signal recieved')
	enabled_buttons -= 1
	if enabled_buttons < required_buttons:
		set_open(false)
	
func set_open(state: bool):
	if state == open:
		return
	
	open = state
	
	if open:
		$Sprite.texture = open_sprite
#		$CollisionShape2D.disabled = true
		layers = 0
	else:
		$Sprite.texture = closed_sprite
#		$CollisionShape2D.disabled = false
		layers = DEFAULT_LAYERS
