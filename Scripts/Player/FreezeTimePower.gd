extends Power
class_name FreezeTimePower

var frozen: bool = false
var duration: float = 2.5
var timer: float = 0.0

func _init():
	id = "freeze_time"
	texture = preload("res://Sprites/Characters/Peppers/spr_blue_pepper_test.png")
	text = "Current Power: Freeze Time"

func use(companion):
	if frozen:
		return
	frozen = true
	timer = duration
	for target in companion.get_tree().get_nodes_in_group("freezable"):
		if target.has_method("set_physics_process"):
			target.set_physics_process(false)
			target.modulate = Color(0.3, 0.3, 1)
		if "frozen" in target:
			target.frozen = true

func update(companion, delta):
	if frozen:
		timer -= delta
		if timer <= 0:
			frozen = false
			for target in companion.get_tree().get_nodes_in_group("freezable"):
				if target.has_method("set_physics_process"):
					target.set_physics_process(true)
					target.modulate = Color(1, 1, 1)
				if "frozen" in target:
					target.frozen = false
					if target.has_method("close"):
						target.close()
