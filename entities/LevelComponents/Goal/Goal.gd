extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group('triggers_goal'): # just player for now
		trigger_goal()
		
func trigger_goal():
	print('wooo!')
	$"/root/Main".next_level()
