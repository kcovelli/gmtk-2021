extends "res://entities/LashableObjects/LashableObject.gd"

#var directional_force = Vector2()

# Default movement values.
#var acceleration = Vector2(100, 1000)
#var velocity = Vector2.ZERO
const GROUND_UNITS_PER_FRAME = 100
const AIR_UNITS_PER_FRAME = 75
const JUMP_FORCE = 100

const MAX_USER_SPEED = 500
const MAX_USER_SPEED_SQ = MAX_USER_SPEED * MAX_USER_SPEED
var curr_user_speed := 0
var last_total_velocity := Vector2()

var grounded = false

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
#	var final_force := Vector2()
	
	# Don't move if you're not changing direction.
#	directional_force = Vector2.ZERO
	
	# user input
	var input := get_user_input()
	var user_influence := Vector2(input[0], 0) * (GROUND_UNITS_PER_FRAME if grounded else AIR_UNITS_PER_FRAME)
	var jump: bool = input[2]
	
	if abs(curr_user_speed + user_influence[0]) <= MAX_USER_SPEED:
		curr_user_speed += user_influence[0]
	else:
		curr_user_speed = sign(curr_user_speed + user_influence[0]) * MAX_USER_SPEED

	
	var velocity = state.get_linear_velocity()
	
	if velocity.length_squared() < MAX_USER_SPEED_SQ or (velocity + user_influence).length_squared() < last_total_velocity.length_squared():
		velocity += user_influence
	
#	velocity += user_influence
	state.set_linear_velocity(velocity)
	last_total_velocity = velocity
#	last_velocity = velocity
#	state.transform.origin += user_influence
	if jump and state.get_contact_count() > 0:
		state.apply_central_impulse(state.get_contact_local_normal(0) * JUMP_FORCE)
		
#	var max_move_speed = 300 + (3700 * int(is_lashing)) -  (175 * int(!grounded))
#	var max_jump_speed = 300 + (600 * int(velocity.y > 0))
#
#	velocity.x += directional_force.x * acceleration.x
#	velocity.y += directional_force.y * acceleration.y
#
#	# Get movement velocity
#	final_force.x = sign(velocity.x) * min(max_move_speed, abs(velocity.x))	
#	final_force.y = sign(velocity.y) * min(max_jump_speed, abs(velocity.y))
#
#	if not grounded and (Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left")):
#		final_force.x = 0
#	state.set_linear_velocity(final_force)

func get_user_input() -> Vector3:
	var h = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var v = -1 if Input.is_action_pressed("ui_up") else 1 if Input.is_action_pressed("ui_down") else 0
	return Vector3(h, v, Input.is_action_pressed("jump"))
	
#func apply_force(state: Physics2DDirectBodyState) -> void:
#	if not is_lashing:		
#		if(Input.is_action_pressed("ui_left")):
#			directional_force += Vector2.LEFT
#		if(Input.is_action_pressed("ui_right")):
#			directional_force += Vector2.RIGHT
#		if(Input.is_action_pressed("ui_up") && grounded):
#			directional_force += Vector2.UP
#			grounded = false
#
#		$Sprite.flip_h =  directional_force.x >= 0


func _on_GroundCheck_body_entered(body: Node) -> void:
	grounded = true
	
func _on_GroundCheck_body_exited(body):
	grounded = false
