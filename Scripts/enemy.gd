extends CharacterBody2D

@export var speed: float = 50
@export var patrol_distance: float = 70
@export var gravity: float = 1000
var direction: int = 1
var start_x: float
var grappled: bool = false
var fainted: bool = false

func _ready():
	start_x = global_position.x
	
func _physics_process(delta):
	if grappled:
		return
	
	if fainted:
		velocity.x = 0
	else:
		velocity.x = speed * direction

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

	if not fainted:
		if global_position.x > start_x + patrol_distance:
			direction = -1
		elif global_position.x < start_x - patrol_distance:
			direction = 1
