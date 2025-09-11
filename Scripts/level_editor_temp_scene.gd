extends Node2D

func _ready() -> void:
	if get_parent() is LevelEditor:
		if !get_parent().created_should_check_for_load:
			return
		get_parent().created_should_check_for_load = false
		var temp_scene = null
		if ResourceLoader.exists("res://Scenes/LevelEditor/temp.tscn"):
			temp_scene = load("res://Scenes/LevelEditor/temp.tscn")
		elif ResourceLoader.exists("res://Scenes/LevelEditor/saved_level.tscn"):
			temp_scene = load("res://Scenes/LevelEditor/saved_level.tscn")
		if temp_scene != null:
			var parent = get_parent()
			parent.call_deferred("remove_child", self)
			var scene = temp_scene.instantiate()
			scene.set_owner(parent)
			parent.call_deferred("add_child", scene)
			parent.tile_map = parent.get_node("TileMap")
			parent.created_scene = parent.get_node("CreatedScene")
			call_deferred("queue_free")
			parent.call_deferred("reset_created_scene_vars")
			DirAccess.remove_absolute("res://Scenes/LevelEditor/temp.tscn")
		return
	for node in get_children():
		if node is EntitySpawn:
			var entity = node.entity.entity_scene.instantiate()
			node.get_parent().add_child(entity)
			entity.global_position = node.global_position
			node.queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("cancel") and ResourceLoader.exists("res://Scenes/LevelEditor/temp.tscn"):
		get_tree().change_scene_to_file("res://Scenes/LevelEditor/level_editor.tscn")
		
