extends RigidBody2D

var resetting = false
var spawned = false

func _physics_process(delta):
	if resetting:
		global_position = Vector2.ZERO
		linear_velocity = Vector2(-200, randi_range(-100, 100))
		resetting = false
	

func respawnBall():
	if spawned:
		queue_free()
	else:
		resetting = true


func _on_area_2d_2_body_entered(body):
	$AudioStreamPlayer2D.play()
