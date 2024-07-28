extends CharacterBody2D

var score = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var input = Input.get_axis("up1", "down1")
	if input:
		velocity = Vector2(0, input) * 500
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.25)
	move_and_slide()

func _on_paddle_zone_2_area_entered(area):
	if area.is_in_group("ball"):
		score += 1
		get_parent().get_node("Score1").text = str(score)
		get_parent().respawnBall()
		get_parent().shakiness += 65
