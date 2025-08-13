extends Area2D

signal pressed
signal released

var pressed_bodies: Array = []

func _on_body_entered(body):
	if not pressed_bodies.has(body):
		pressed_bodies.append(body)
	if pressed_bodies.size() == 1:
		emit_signal("pressed")

func _on_body_exited(body):
	pressed_bodies.erase(body)
	if pressed_bodies.is_empty():
		emit_signal("released")
