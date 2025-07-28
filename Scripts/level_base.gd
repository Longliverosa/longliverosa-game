extends Resource
class_name LevelBase

@export var name : String = ""
@export var order : int = 0
@export var depends_on : int = -1
@export var scene : PackedScene 
@export var icon : Texture2D 

var locked : bool = false
var completed : bool = false
