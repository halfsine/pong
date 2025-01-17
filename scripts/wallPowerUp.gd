extends Node2D

func _on_area_2d_area_exited(area):
	if area.is_in_group("ball"):
		var wall = load("res://prefabs/temporaryWall.tscn").instantiate()
		wall.position = global_position
		get_parent().call_deferred("add_child", wall)
		queue_free()
