extends Node2D



func _on_Area2D_body_entered(body):
	if body.is_in_group('triggers_goal'):
		trigger_goal()
		
func trigger_goal():
	print('wooo!')
	$"/root/Main".next_level()
