extends Power
class_name BasicAttackPower

const BASIC_ATTACK_RANGE = 150.0

func _init():
	id = "basic_attack"
	texture = preload("res://Sprites/Characters/Peppers/pip_pepper.png")
	text = "Current Power: Basic Attack"

func use(companion):
	companion._attack_or_break_nearest("attackable")

func can_use(_companion) -> bool:
	return _companion._find_nearest_in_group("attackable", BASIC_ATTACK_RANGE) != null
