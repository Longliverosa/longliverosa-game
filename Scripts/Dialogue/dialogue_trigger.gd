extends Area2D

@export var dialogue_label: String = ""

signal dialogue_triggered(label:String)

func _ready():
	self.body_entered.connect(Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is not CharacterBody2D or body.name != "Player":
		return
	emit_signal("dialogue_triggered",dialogue_label)
