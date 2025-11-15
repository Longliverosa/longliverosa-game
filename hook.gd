extends Node2D

# Chenged in point_a and point_b are relative to the position the scene is placed at
# For example, if place at (100, 0) and point_b is set to (100, 0) the global point_b will be (200, 0)
@export var point_a: Vector2
@export var point_b: Vector2
@export var speed: float = 1.0 

func _ready():
	point_a = point_a + position
	point_b = point_b + position
	hook_move()


func hook_move():
	# Create a looping tween sequence
	var tween = create_tween().set_loops()  

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Move A → B
	tween.tween_property(self, "position", point_b, speed)

	# Move B → A
	tween.tween_property(self, "position", point_a, speed)
