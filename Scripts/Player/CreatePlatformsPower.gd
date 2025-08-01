extends Power
class_name CreatePlatformsPower

func _init():
	id = "create_platforms"
	texture = preload("res://Sprites/Characters/Peppers/spr_purple_pepper_test.png")
	text = "Current Power: Creates Platforms"

func use(companion):
	companion._spawn_eye_platform()
