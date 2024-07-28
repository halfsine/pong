extends CharacterBody2D

var score = 0
var input = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	input = Input.get_axis("up1", "down1")
	if input:
		velocity = Vector2(0, input) * 500
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.25)
	move_and_slide()

func _on_paddle_zone_2_area_entered(area):
	if area.is_in_group("ball"):
		score += 1
		get_parent().get_node("Score1").text = str(score)
		area.get_parent().respawnBall()
		get_parent().shakiness += 65
		get_parent().get_node("PaddleZone1/AudioStreamPlayer2D").play()
	elif area.is_in_group("saw"):
		area.get_parent().queue_free()

func breakPaddle():
	visible = false
	set_collision_layer_value(1, false)
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(5).timeout
	$AnimationPlayer.play("respawn")
	await $AnimationPlayer.animation_finished
	set_collision_layer_value(1, true)
