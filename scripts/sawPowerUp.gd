extends Node2D

func _on_area_2d_area_exited(area):
	if area.is_in_group("ball"):
		var saw = load("res://prefabs/saw.tscn").instantiate()
		saw.position = global_position
		get_parent().call_deferred("add_child", saw)
		queue_free()
