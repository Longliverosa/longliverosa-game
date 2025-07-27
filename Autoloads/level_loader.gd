extends Node

enum Difficulty { EASY, NORMAL, HARD }

var all_levels : Array[Node2D] = [] 

func _ready() -> void:
	load_levels() 
	# Pick random level from list, generate stuff inside?

func load_levels():
	for file in get_all_file_paths("res://Scenes/Levels"):
		var level = load(file)
		if(level is Node2D):
			all_levels.append(level)

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths
