extends Sprite2D

var speed: float = 100.0
var left_limit: float = -100.0
var right_limit: float = 100.0
var direction: int = 1 
var start_x: float

func _ready():
	start_x = global_position.x

func _process(delta: float):
	global_position.x += speed * direction * delta
	if global_position.x > start_x + right_limit:
		global_position.x = start_x + right_limit
		direction = -1
	elif global_position.x < start_x + left_limit:
		global_position.x = start_x + left_limit
		direction = 1
