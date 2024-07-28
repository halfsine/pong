extends Node2D

func _on_area_2d_area_exited(area):
	if area.is_in_group("ball"):
		var bomb = load("res://prefabs/bomb.tscn").instantiate()
		bomb.position = global_position
		get_parent().call_deferred("add_child", bomb)
		queue_free()
