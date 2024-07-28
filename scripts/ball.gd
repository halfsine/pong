extends RigidBody2D

var resetting = false

func _physics_process(delta):
	if resetting:
		global_position = Vector2.ZERO
		linear_velocity = Vector2(-200, randi_range(-100, 100))
		resetting = false
	
