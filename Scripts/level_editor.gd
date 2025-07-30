extends Control

@onready var tile_map : TileMapLayer = %TileMap
@onready var item_select : ItemList = %ItemSelect
@onready var category_select : ItemList = %CategorySelect
@onready var camera : Camera2D = %Camera
@onready var created_scene : Node2D = %CreatedScene

@export var entity_placeholder_scene : PackedScene

const MOVE_SPEED = 150
enum Categories {TILES = 0, ENTITIES = 1}

var should_flip : bool = false
var tiles : Array[String]
var entities : Array[EntityBase]
var current_tile_index : int = Categories.TILES
var current_category : int = Categories.TILES
 
func _ready() -> void:
	for i in range(tile_map.tile_set.get_terrains_count(0)):
		tiles.append(tile_map.tile_set.get_terrain_name(0, i))
	set_item_select_for_category(Categories.TILES)
	category_select.select(0)
	for file in LevelLoader.get_all_file_paths("res://Scenes/Entities"):
		var entity = load(file)
		if(entity is EntityBase):
			entities.append(entity)
			
	tile_map.set_owner(created_scene)

func _on_category_select_item_selected(index: int) -> void:
	set_item_select_for_category(index)

func set_item_select_for_category(category : int) -> void:
	item_select.clear()
	current_category = category
	if category == Categories.TILES:
		for tile in tiles:
			item_select.add_item(tile)
	elif category == Categories.ENTITIES:
		for entity in entities:
			item_select.add_item(entity.name, entity.icon)	
	item_select.select(0)

func _on_item_select_item_selected(index: int) -> void:
	current_tile_index = index

func _unhandled_input(_event: InputEvent) -> void:
	if current_category == Categories.TILES:
		var selected_tile = tile_map.local_to_map(get_local_mouse_position())
		if Input.is_action_pressed("click"):
			tile_map.set_cells_terrain_connect([selected_tile], 0, current_tile_index)
		if Input.is_action_pressed("alt_click"):
			tile_map.set_cells_terrain_connect([selected_tile], 0, -1)
	elif current_category == Categories.ENTITIES:
		if Input.is_action_pressed("click"):
			var scene = entity_placeholder_scene.instantiate()
			scene.position = get_local_mouse_position() + Vector2(-20, -20)
			if should_flip:
				scene.flip_h = true
			scene.entity = entities[current_tile_index]
			scene.set_icon()
			created_scene.add_child(scene, true)
			scene.set_owner(created_scene)
	if Input.is_action_pressed("pepper_power"):
		should_flip = !should_flip
		
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
	packed_scene.pack(created_scene)
	ResourceSaver.save(packed_scene, "res://Scenes/LevelEditor/saved_level.tscn")
