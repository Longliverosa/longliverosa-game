extends Control

@onready var tile_map : TileMapLayer = %TileMap
@onready var item_select : ItemList = %ItemSelect
@onready var category_select : ItemList = %CategorySelect
@onready var camera : Camera2D = %Camera

const MOVE_SPEED = 150

var tiles : Array[String]
var current_tile_index : int = 0
 
func _ready() -> void:
	for i in range(tile_map.tile_set.get_terrains_count(0)):
		tiles.append(tile_map.tile_set.get_terrain_name(0, i))
	set_item_select_for_category(0)
	category_select.select(0)

func _on_category_select_item_selected(index: int) -> void:
	set_item_select_for_category(index)

func set_item_select_for_category(category : int) -> void:
	item_select.clear()
	if category == 0:
		for tile in tiles:
			item_select.add_item(tile)
		item_select.select(0)

func _on_item_select_item_selected(index: int) -> void:
	current_tile_index = index

func _unhandled_input(_event: InputEvent) -> void:
	var selected_tile = tile_map.local_to_map(get_local_mouse_position())
	
	if Input.is_action_pressed("click"):
		tile_map.set_cells_terrain_connect([selected_tile], 0, current_tile_index)
	if Input.is_action_pressed("alt_click"):
		tile_map.set_cells_terrain_connect([selected_tile], 0, -1)

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_down"):
		camera.global_position.y += MOVE_SPEED * delta  
	if Input.is_action_pressed("move_left"):
		camera.global_position.x -= MOVE_SPEED * delta 
	if Input.is_action_pressed("move_right"):
		camera.global_position.x += MOVE_SPEED * delta 
	if Input.is_action_pressed("move_up"):
		camera.global_position.y -= MOVE_SPEED * delta 


func _on_save_button_pressed() -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(tile_map)
	ResourceSaver.save(packed_scene, "res://Scenes/LevelEditor/saved_level.tscn")
