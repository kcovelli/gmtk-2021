extends "res://entities/LashableObjects/LashableObject.gd"

#var directional_force = Vector2()

# Default movement values.
#var acceleration = Vector2(100, 1000)
#var velocity = Vector2.ZERO
const GROUND_UNITS_PER_FRAME = 50
const AIR_UNITS_PER_FRAME = 10
const JUMP_FORCE = 300

const AIRIAL_LINEAR_DAMP = 0.1
const GROUND_LINEAR_DAMP = 0.1
const AIRIAL_ANGULAR_DAMP = 5
const GROUND_ANGULAR_DAMP = 5


const MAX_USER_SPEED = 200
const MAX_USER_SPEED_SQ = MAX_USER_SPEED * MAX_USER_SPEED
const MAX_GROUNDED_NORM_ANGLE = PI/4

onready var RB := $'.'

var curr_user_speed := 0
var last_total_velocity := Vector2()
var contact_norm := Vector2()
var grounded = false
var calls_since_jump = 0

var last_norm := Vector2()
var all_norms = []

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	
	contact_norm = get_most_vertical_norm(state)
	grounded = abs(contact_norm.angle() + PI/2) < PI/4
	
	if grounded:
		RB.angular_damp = GROUND_ANGULAR_DAMP
		RB.linear_damp = GROUND_LINEAR_DAMP
#		if not Globals.vec_equal_approx(contact_norm, last_norm):
#			print(contact_norm, ' ', rad2deg(contact_norm.angle()))
	else:
		RB.angular_damp = AIRIAL_ANGULAR_DAMP
		RB.linear_damp = AIRIAL_LINEAR_DAMP
		
	
	var input := get_user_input()
	var user_influence := Vector2(input[0], 0) * (GROUND_UNITS_PER_FRAME if grounded else AIR_UNITS_PER_FRAME)
	var jump: bool = input[2]

	var velocity = state.get_linear_velocity()
	
	if velocity.length_squared() < MAX_USER_SPEED_SQ or (velocity + user_influence).length_squared() < last_total_velocity.length_squared():
		velocity += user_influence

	state.set_linear_velocity(velocity)
	last_total_velocity = velocity
	
	if jump and grounded and calls_since_jump > 5:
		state.apply_central_impulse(contact_norm * JUMP_FORCE)
		calls_since_jump = 0
	else:
		calls_since_jump += 1
	
	if contact_norm != Vector2():
		last_norm = contact_norm
	$'/root/Main'.update()

func get_user_input() -> Vector3:
	var h = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var v = -1 if Input.is_action_pressed("ui_up") else 1 if Input.is_action_pressed("ui_down") else 0
	return Vector3(h, v, Input.is_action_pressed("jump"))

	


func get_most_vertical_norm(state: Physics2DDirectBodyState) -> Vector2:
	var n_norms = state.get_contact_count()
	if n_norms == 0:
		return Vector2()
	if n_norms == 1:
		all_norms = [state.get_contact_local_normal(0)]
		return state.get_contact_local_normal(0)
	all_norms = []
	var min_norm = null
	var min_angle = 50000 # any angle will be less than 2PI so whatever
	var a = 0
	var n: Vector2
	for i in range(n_norms):
		n = state.get_contact_local_normal(i)
		all_norms.append(n)
		a = abs(n.angle() + PI/2)
		if a < min_angle:
			min_norm = n
			min_angle = a
			all_norms[i] =all_norms[0]
			all_norms[0] = min_norm
	assert(min_norm == all_norms[0])
	return min_norm
			
