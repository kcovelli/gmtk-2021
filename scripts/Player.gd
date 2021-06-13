extends "res://scripts/LashableObject.gd"

var directional_force = Vector2()

# Default movement values.
var acceleration = Vector2(100, 1000)
var velocity = Vector2.ZERO


var grounded = false

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	var final_force := Vector2()
	
	# Don't move if you're not changing direction.
	directional_force = Vector2.ZERO
	
	# Apply force on character
	apply_force(state)
	
	velocity = state.get_linear_velocity()
	
	var max_move_speed = 300 + (3700 * int(is_lashing)) -  (175 * int(!grounded))
	var max_jump_speed = 300 + (600 * int(velocity.y > 0))
	
	velocity.x += directional_force.x * acceleration.x
	velocity.y += directional_force.y * acceleration.y
	
	# Get movement velocity
	final_force.x = sign(velocity.x) * min(max_move_speed, abs(velocity.x))	
	final_force.y = sign(velocity.y) * min(max_jump_speed, abs(velocity.y))

	if not grounded and (Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left")):
		final_force.x = 0
	state.set_linear_velocity(final_force)
	
func apply_force(state: Physics2DDirectBodyState) -> void:
	if not is_lashing:		
		if(Input.is_action_pressed("ui_left")):
			directional_force += Vector2.LEFT
		if(Input.is_action_pressed("ui_right")):
			directional_force += Vector2.RIGHT
		if(Input.is_action_pressed("ui_up") && grounded):
			directional_force += Vector2.UP
			grounded = false
		
		$Sprite.flip_h =  directional_force.x >= 0


func _on_GroundCheck_body_entered(body: Node) -> void:
	grounded = true
	


