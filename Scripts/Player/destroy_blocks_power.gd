extends Power
class_name DestroyBlocksPower

func _init():
	id = "destroy_blocks"
	texture = preload("res://Assets/Sprites/Characters/Peppers/spr_yellow_pepper_test.png")
	text = "Current Power: Destroy Blocks"

func use(companion):
	companion._attack_or_break_nearest("breakable")
