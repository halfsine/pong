extends Node2D

var noisePos = 0
var shakiness = 0

@onready var bus := AudioServer.get_bus_index("Master")

var reactionTime = 1.501

@export var powerups : Array[Resource]

func _process(delta):
	if shakiness:
		shakiness = lerpf(shakiness, 0, 0.1)
		$Camera2D.position.x = lerp($Camera2D.position.x, randf_range(-shakiness, shakiness), 0.25)
		$Camera2D.position.y = lerp($Camera2D.position.y, randf_range(-shakiness, shakiness), 0.25)
	else:
		$Camera2D.position = $Camera2D.position.lerp(Vector2.ZERO, 0.25)

func _on_v_slider_value_changed(value):
	$Paddle2/Above/CollisionShape2D.shape.size.x = value
	$Paddle2/Below/CollisionShape2D.shape.size.x = value
	#$Paddle2/ThinkTick.wait_time = reactionTime - (value / 1000)
	print($Paddle2/ThinkTick.wait_time)

func _input(event):
	if Input.is_action_just_pressed("menu"):
		if get_tree().paused:
			get_tree().paused = false
			$Camera2D/Control/Panel.visible = false
			$Camera2D/Control/Settings.visible = false
		else:
			get_tree().paused = true
			$Camera2D/Control/Panel.visible = true

func _on_power_up_timer_timeout():
	var powerupNumber = randi_range(0, len(powerups) - 1)
	var powerup = powerups[powerupNumber].instantiate()
	powerup.position.y = randi_range(-400, 400)
	powerup.position.x = randi_range(-400, 400)
	$PowerUps.add_child(powerup)


func _on_options_pressed():
	$Camera2D/Control/Settings.visible = true

func _on_back_pressed():
	$Camera2D/Control/Panel.visible = false
	$Camera2D/Control/Settings.visible = false
	get_tree().paused = false

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _ready():
	$Camera2D/Control/Settings/VolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(bus))
