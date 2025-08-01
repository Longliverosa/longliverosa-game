extends Power
class_name GrapplingHookPower

func _init():
	id = "grappling_hook"
	texture = preload("res://Sprites/Characters/Peppers/spr_green_pepper_test.png")
	text = "Current Power: Grappling Hook"

func use(companion):
	companion._start_grapple()
