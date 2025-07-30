extends Control

@export var entity : EntityBase

var is_mouse_on_me : bool = false

func set_icon():
	self.texture = entity.icon

func _process(delta) -> void:
	if Input.is_action_pressed("alt_click") and is_mouse_on_me:
		queue_free()
		

func _on_mouse_entered() -> void:
	is_mouse_on_me = true


func _on_mouse_exited() -> void:
	is_mouse_on_me = false
