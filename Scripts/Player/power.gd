extends RefCounted
class_name Power

var id: String
var texture: Texture
var text: String

func use(_companion) -> void:
	pass
	
func can_use(_companion) -> bool:
	return true
	
func update(_companion, _delta) -> void:
	pass
	
func on_select(_companion) -> void:
	pass
	
func on_deselect(_companion) -> void:
	pass
