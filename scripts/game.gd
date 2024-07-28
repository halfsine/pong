extends Node2D

@export var ball : RigidBody2D

@export var shakeNoise = FastNoiseLite.new()
var noisePos = 0
var shakiness = 0

@export var powerups : Array[Resource]

func _process(delta):
	if shakiness:
		shakiness = lerpf(shakiness, 0, 0.1)
		$Camera2D.offset.x = lerp($Camera2D.offset.x, randf_range(-shakiness, shakiness), 0.25)
		$Camera2D.offset.y = lerp($Camera2D.offset.y, randf_range(-shakiness, shakiness), 0.25)
	else:
		$Camera2D.offset = $Camera2D.offset.lerp(Vector2.ZERO, 0.25)

func respawnBall():
	ball.resetting = true

func _on_v_slider_value_changed(value):
	$Paddle2/Above/CollisionShape2D.shape.size.x = value
	$Paddle2/Below/CollisionShape2D.shape.size.x = value

func _input(event):
	if Input.is_action_just_pressed("menu"):
		if get_tree().paused:
			get_tree().paused = false
			$Camera2D/Control/Panel.visible = false
		else:
			get_tree().paused = true
			$Camera2D/Control/Panel.visible = true

func _on_power_up_timer_timeout():
	var powerupNumber = randi_range(0, len(powerups) - 1)
	var powerup = powerups[powerupNumber].instantiate()
	powerup.position.y = randi_range(-400, 400)
	powerup.position.x = randi_range(-400, 400)
	$PowerUps.add_child(powerup)
	
