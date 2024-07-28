extends CharacterBody2D

var score = 0
var isAi = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var input = 0
	if isAi:
		
		for node in $Below.get_overlapping_areas():
			if node.is_in_group("ball"):
				input += 1
				
		for node in $Above.get_overlapping_areas():
			if node.is_in_group("ball"):
				input -= 1
		
	else:
		input = Input.get_axis("up2", "down2")
	
	if input:
		velocity = Vector2(0, input) * 500
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.25)
	move_and_slide()


func _on_paddle_zone_1_area_entered(area):
	if area.is_in_group("ball"):
		score += 1
		get_parent().get_node("Score2").text = str(score)
		area.get_parent().respawnBall()
		get_parent().shakiness += 65
