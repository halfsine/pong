extends CharacterBody2D

var score = 0
var isAi = true
var input = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !isAi:
		input = 0
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
		get_parent().get_node("PaddleZone2/AudioStreamPlayer2D").play()


func _on_think_tick_timeout():
	if isAi:
		input = 0
		for node in $Below.get_overlapping_areas():
			if node.is_in_group("ball"):
				input = 1
					
		for node in $Above.get_overlapping_areas():
			if node.is_in_group("ball"):
				input = -1

func breakPaddle():
	visible = false
	set_collision_layer_value(1, false)
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(5).timeout
	$AnimationPlayer.play("respawn")
	await $AnimationPlayer.animation_finished
	set_collision_layer_value(1, true)
