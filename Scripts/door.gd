extends Node2D
class_name Door

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var is_open: bool = false
var frozen: bool = false

func open():
	if not frozen:
		is_open = true
		collider.set_deferred("disabled", true)
		sprite.modulate = Color(0.5, 0.5, 0.5)

func close():
	if not frozen:
		is_open = false
		collider.set_deferred("disabled", false)
		sprite.modulate = Color(1, 1, 1)
