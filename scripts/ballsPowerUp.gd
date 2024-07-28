extends Node2D

func _on_area_2d_area_exited(area):
	if area.is_in_group("ball"):
		var ball = load("res://prefabs/ball.tscn").instantiate()
		ball.position = global_position
		ball.spawned = true
		get_parent().call_deferred("add_child", ball)
		queue_free()
