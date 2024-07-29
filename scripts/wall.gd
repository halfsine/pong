extends StaticBody2D

var hits = 3

func _on_area_2d_area_exited(area):
	if area.is_in_group("ball"):
		hits -= 1
		$ColorRect.color -= Color8(50, 0, 0, 0)
		if hits < 1:
			queue_free()
