extends Node2D

func _ready():
	$Button.connect("pressed", Callable($Door, "open"))
	$Button.connect("released", Callable($Door, "close"))
