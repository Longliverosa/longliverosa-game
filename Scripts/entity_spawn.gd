extends Control
class_name EntitySpawn

@export var entity : EntityBase

var is_mouse_on_me : bool = false

func set_icon():
	self.texture = entity.icon

func _process(_delta) -> void:
	var level_editor : LevelEditor = get_parent().get_parent()
	if Input.is_action_pressed("alt_click") and is_mouse_on_me \
	and level_editor.current_category == level_editor.Categories.ENTITIES:
		if entity.name == "Player":
			for i in range(level_editor.item_select.item_count):
				if level_editor.entities[i].name == "Player":
					level_editor.item_select.set_item_disabled(i, false)
					level_editor.is_player_placed = false
					break
		queue_free()
		

func _on_mouse_entered() -> void:
	is_mouse_on_me = true


func _on_mouse_exited() -> void:
	is_mouse_on_me = false
