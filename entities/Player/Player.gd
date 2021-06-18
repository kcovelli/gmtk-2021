extends "res://entities/LashableObjects/LashableObject.gd"


# Default movement values.
const GROUND_UNITS_PER_FRAME = 50
const AIR_UNITS_PER_FRAME = 5
const LASHED_UNITS_PER_FRAME = 25 # TODO: implement and test value
const JUMP_FORCE = 300

# Dampening values
const GROUND_LINEAR_DAMP = 0.1
const GROUND_ANGULAR_DAMP = 5
const AIRIAL_LINEAR_DAMP = 0.1
const AIRIAL_ANGULAR_DAMP = 5
const LASHING_LINEAR_DAMP = 1
const LASHING_ANGULAR_DAMP = 8

# Maximum speed that can be contributed by user input
const MAX_USER_SPEED = 200
const MAX_USER_SPEED_SQ = MAX_USER_SPEED * MAX_USER_SPEED

# Max angle (rads) the most vertical contact normal can be for the player to be considered "grounded"
const MAX_GROUNDED_NORM_ANGLE = PI/8

# reference to the player's rigidbody. no idea why we can't just access the fields directly but whatever
onready var rb := $'.'

# current 
var curr_user_speed := 0
var last_total_velocity := Vector2()
var contact_norm := Vector2()
var grounded = false

# after jumping we are sometimes still on the ground for a couple frames, 
# so we don't want to apply the jump impulse multiple times
var calls_since_jump = 0

# list of current contact norms. 0th index is the "most vertical". just used for debug for now
var all_norms = []

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	
	# get norm from the "flattest" collision, and check if it is within the range to be considered grounded
	contact_norm = get_most_vertical_norm(state)
	grounded = abs(contact_norm.angle() + PI/2) < MAX_GROUNDED_NORM_ANGLE
	
	# apply dampening
	if is_lashing:
		rb.angular_damp = LASHING_ANGULAR_DAMP
		rb.linear_damp = LASHING_LINEAR_DAMP
		print("player lashing")
	elif grounded:
		rb.angular_damp = GROUND_ANGULAR_DAMP
		rb.linear_damp = GROUND_LINEAR_DAMP
	else:
		rb.angular_damp = AIRIAL_ANGULAR_DAMP
		rb.linear_damp = AIRIAL_LINEAR_DAMP
	
		
	
	# get user input, up/down not used for anything currently
	var input := get_user_input()
	var user_influence := Vector2(input[0], 0) * (GROUND_UNITS_PER_FRAME if grounded else AIR_UNITS_PER_FRAME)
	var jump: bool = input[2]

	var velocity = state.get_linear_velocity()
	
	# only apply the velocity from user input if total velocity is less than the max, or applying it would slow us down
	# TODO: technically we should keep track of how much speed has been added by user and check against that separately 
	if velocity.length_squared() < MAX_USER_SPEED_SQ or (velocity + user_influence).length_squared() < last_total_velocity.length_squared():
		velocity += user_influence

	state.set_linear_velocity(velocity)
	last_total_velocity = velocity
	
	# apply jump impulse
	if jump and grounded and calls_since_jump > 5:
		state.apply_central_impulse(contact_norm * JUMP_FORCE)
		calls_since_jump = 0
	else:
		calls_since_jump += 1
	
	if Globals.DRAW_DEBUG_NORMS:
		$'/root/Main'.update()

func get_user_input() -> Vector3:
	var h = -1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0
	var v = -1 if Input.is_action_pressed("ui_up") else 1 if Input.is_action_pressed("ui_down") else 0
	return Vector3(h, v, Input.is_action_pressed("jump"))


# Loop over all reported collisions, and get the norm of the collision whose norm is closest to 90 deg from horizontal
# TODO: this code looks gross, refactor
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
		# n.angle() returns angle clockwise from x axis. don't remember why this is +PI/2 instead of -PI/2 then lmao
		a = abs(n.angle() + PI/2) 
		if a < min_angle:
			min_norm = n
			min_angle = a
			all_norms[i] =all_norms[0]
			all_norms[0] = min_norm
	assert(min_norm == all_norms[0])
	return min_norm
			
