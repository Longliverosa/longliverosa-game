extends StaticBody2D

@export var lifetime: float = 1.0

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()
