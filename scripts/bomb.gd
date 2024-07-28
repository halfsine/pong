extends RigidBody2D

var resetting = false
var spawned = false

func _physics_process(delta):
	if resetting:
		global_position = Vector2.ZERO
		linear_velocity = Vector2(-200, randi_range(-100, 100))
		resetting = false

func _on_area_2d_2_body_entered(body):
	$AudioStreamPlayer2D.play()

func _on_timer_timeout():
	$Bomb.visible = true
	freeze = true
	$Explosion.visible = true
	for node in $Area2D.get_overlapping_bodies():
		if node.is_in_group("paddle"):
			node.breakPaddle()
	await get_tree().create_timer(1).timeout
	queue_free()
