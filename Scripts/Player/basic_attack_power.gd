extends Power
class_name BasicAttackPower

const BASIC_ATTACK_RANGE = 60.0

func _init():
	id = "basic_attack"
	texture = preload("res://Sprites/Characters/Peppers/pip_pepper.png")
	text = "Current Power: Basic Attack"
	
func use(companion):
	companion._attack(BASIC_ATTACK_RANGE)

func can_use(_companion) -> bool:
	return true
