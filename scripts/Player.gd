extends "res://scripts/LashableObject.gd"

var directional_force = Vector2()

# Default movement values.
var acceleration = 1000
var max_move_speed = 200
var max_jump_speed = 400
var grounded = false

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
	
	if not grounded and (Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left")):
		final_force.x = 0
	state.set_linear_velocity(final_force)
	

func _ready():
	# Player specific movement values.
	var acceleration = 1000
	var max_move_speed = 200
	var max_jump_speed = 400
	
func apply_force(state: Physics2DDirectBodyState) -> void:
			
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

