extends Area2D

signal pressed
signal released

@onready var sprite_inactive : Sprite2D = $Sprite2D
@onready var sprite_active : Sprite2D = $Sprite2D_ACTIVE

var pressed_bodies: Array = []

func _on_body_entered(body):
	if not pressed_bodies.has(body) and body is CharacterBody2D:
		pressed_bodies.append(body)
	if pressed_bodies.size() > 0:
		sprite_active.visible = true
		sprite_inactive.visible = false
		pressed.emit()

func _on_body_exited(body):
	pressed_bodies.erase(body)
	if pressed_bodies.is_empty():
		sprite_active.visible = false
		sprite_inactive.visible = true
		released.emit()
