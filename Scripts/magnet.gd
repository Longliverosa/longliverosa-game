extends CharacterBody2D
class_name MagnetizableObject

@export var gravity: int = 50
@export var max_fall_speed: int = 300
@export var magnet_pull_speed: float = 100.0

var is_magnetized: bool = false
var magnet_target: Node2D = null

func _physics_process(delta):
	if is_magnetized and magnet_target:
		var dir = (magnet_target.global_position - global_position).normalized()
		velocity = dir * magnet_pull_speed
	else:
		if not is_on_floor():
			velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
		else:
			velocity.y = 0
		velocity.x = 0

	move_and_slide()
