extends Power
class_name RemoteControlPower

var cooldown: float = 0.0
var cooldown_time: float = 2.5

func _init():
	id = "remote_control"
	texture = preload("res://Sprites/Characters/Peppers/spr_grey_pepper_test.png")
	text = "Current Power: Remote Control"

func use(companion):
	if cooldown <= 0:
		companion.controlling = !companion.controlling
		companion.player_body.controlling = companion.controlling
		companion.camera.enabled = !companion.controlling
		companion.subcamera.enabled = companion.controlling
		companion.fuel = companion.max_fuel
		companion.fuel_bar.visible = companion.controlling
		companion.fuel_label.visible = companion.controlling
		if not companion.controlling:
			cooldown = cooldown_time

func update(_companion, delta):
	if cooldown > 0:
		cooldown -= delta
