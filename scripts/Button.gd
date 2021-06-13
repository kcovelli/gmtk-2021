extends Node2D

var activated = false setget set_active

var active_sprite = preload("res://assets/objects/tile_0128.png")
var inactive_sprite = preload("res://assets/objects/tile_0129.png")

func _on_Area2D_body_entered(body):
	set_active(true)

func _on_Area2D_body_exited(body):
	set_active(false)

func set_active(state: bool):
	if state == activated:
		return
	
	activated = state
	if activated:
		$Sprite.texture = active_sprite
	else:
		$Sprite.texture = inactive_sprite
