extends Power
class_name RemoteControlPower

func _init():
	id = "remote_control"
	texture = preload("res://Sprites/Characters/Peppers/spr_grey_pepper_test.png")
	text = "Current Power: Remote Control"

func use(companion):
	if companion.remote_cooldown <= 0:
		companion.controlling = !companion.controlling
		companion.player_body.controlling = companion.controlling
		companion.camera.enabled = !companion.controlling
		companion.subcamera.enabled = companion.controlling
		companion.fuel = companion.max_fuel
		companion.fuel_bar.visible = companion.controlling
		companion.fuel_label.visible = companion.controlling
		if not companion.controlling:
			companion.remote_cooldown = companion.remote_cooldown_time
