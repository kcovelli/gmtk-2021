extends RigidBody2D


var directional_force = Vector2()

# Default movement values.
var acceleration = 1000
var max_move_speed = 200
var max_jump_speed = 400

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	var final_force := Vector2()
	
	# Don't move if you're not changing direction.
	directional_force = Vector2.ZERO
	
	# Apply force on character
	apply_force(state)
	
	final_force = state.get_linear_velocity() + (directional_force * acceleration)
	
	# Get movement velocity
	final_force.x = sign(final_force.x) * min(max_move_speed, abs(final_force.x))
	
	final_force.y = sign(final_force.y) * min(max_jump_speed, abs(final_force.y))
	
	state.set_linear_velocity(final_force)
	
	
func apply_force(state: Physics2DDirectBodyState) -> void:
	pass
