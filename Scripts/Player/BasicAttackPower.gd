extends Power
class_name BasicAttackPower

func _init():
	id = "basic_attack"
	texture = preload("res://Sprites/Characters/Peppers/spr_orange_pepper_test.png")
	text = "Current Power: Basic Attack"

func use(companion):
	companion._attack_or_break_nearest("enemy")
