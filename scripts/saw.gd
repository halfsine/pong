extends RigidBody2D

func _physics_process(delta):
	for node in $Area2D.get_overlapping_bodies():
		if node.is_in_group("paddle"):
			node.breakPaddle()
			get_parent().get_parent().shakiness += 100

func _on_area_2d_2_body_entered(body):
	$AudioStreamPlayer2D.play() 
