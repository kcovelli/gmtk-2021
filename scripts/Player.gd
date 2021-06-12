extends "res://scripts/Character.gd"


const MAX_JUMP_TIME =  0.1

# Check whether or not a character is on the ground.
var grounded = false 
var can_jump = false
var jump_time = 0

func _ready():
	# Player specific movement values.
	var acceleration = 1000
	var max_move_speed = 200
	var max_jump_speed = 400
	
func apply_force(state: Physics2DDirectBodyState) -> void:
	if(grounded):
		# Reset jumping.
		can_jump = true
		jump_time = 0
		
	if(Input.is_action_pressed("ui_left")):
		directional_force += Vector2.LEFT
		
	if(Input.is_action_pressed("ui_right")):
		directional_force += Vector2.RIGHT
	
	if(Input.is_action_pressed("ui_up") && jump_time < MAX_JUMP_TIME && can_jump):
		directional_force += Vector2.UP
		jump_time += state.get_step()
		
	elif(Input.is_action_just_released("ui_up")):
		can_jump = false


func _on_GroundCheck_body_entered(body: Node) -> void:
	print('grounded!')
	grounded = true


func _on_GroundCheck_body_exited(body: Node) -> void:
	print('not grounded...')
	grounded = false
