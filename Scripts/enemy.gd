extends CharacterBody2D

var speed: float = 50
var left_limit: float = -70
var right_limit: float = 70
var direction: int = 1 
var start_x: float

func _ready():
	start_x = global_position.x

func _physics_process(delta):
	var motion = Vector2(speed * direction * delta, 0)
	var collision = move_and_collide(motion)
	if collision:
		direction = -direction
	else:
		global_position += motion

	if global_position.x > start_x + right_limit:
		global_position.x = start_x + right_limit
		direction = -1
	elif global_position.x < start_x + left_limit:
		global_position.x = start_x + left_limit
		direction = 1
