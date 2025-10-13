extends Node2D
class_name Enemy

enum MoveMode { Patrol, Path, None }
enum AttackMode { Passive, Neutral, Aggressive }

@export_group("Information")
@export var health: int = 2

@export_group("Graphics")
@export var flip_sprite_with_direction: bool = true

@export_group("Movement")
@export var speed: float = 50
@export var chase_speed: float = 60
@export var movement_mode: MoveMode = MoveMode.Patrol
@export var patrol_distance: float = 70
@export var gravity: float = 1000

@export_group("Behaviour")
@export var attack_mode: AttackMode = AttackMode.Passive
@export var aggro_enter_range: float = 30
@export var aggro_exit_range: float = 30

@onready var sprite_node: Sprite2D = $"Enemy/GFX"
@onready var aggro_enter_shape: CollisionShape2D = $"Enemy/AggroEnterArea/AggroShape"
@onready var aggro_exit_shape: CollisionShape2D = $"Enemy/AggroExitArea/AggroShape"
@onready var character_body: CharacterBody2D = $"Enemy"
@onready var wait_timer: Timer  = $"WaitTimer"

var is_neutral_and_attacked: bool = false
var wait_pos: Vector2 = Vector2.ZERO
var look_direction: int = 1
var move_direction: Vector2 = Vector2.ZERO
var grappled: bool = false
var fainted: bool = false
var current_gravity: float = 0

var is_aggro: bool = false
@onready var target: Node2D = $"Target"
var player_body: Node2D
var stuck_timer: float = 0 

func _ready():
	character_body.add_to_group("attackable")
	character_body.add_to_group("freezable")
	character_body.add_to_group("pullable")
	wait_timer.one_shot = true
	aggro_enter_shape.shape.radius = aggro_enter_range
	aggro_exit_shape.shape.radius = aggro_exit_range
	
func _physics_process(delta):
	if grappled:
		return
	
	if fainted:
		character_body.velocity.x = 0
	else:
		var current_target = calculate_target()
		calculate_directions(current_target)
		if is_close_to_target(current_target):
			if not is_aggro:
				reset_target_to_random(false)
		else:
			character_body.velocity = calculate_velocity()
		
		if flip_sprite_with_direction:
			var flip = determine_sprite_flip()
			sprite_node.flip_h = flip.x == 1
			sprite_node.flip_v = flip.y == 1

	calculate_gravity(delta)

	character_body.move_and_slide()
	check_if_stuck(delta)

func determine_sprite_flip() -> Vector2:
	return Vector2(look_direction == -1, 0)

func calculate_velocity() -> Vector2:
	return (speed if not is_aggro else chase_speed) * (move_direction if gravity == 0 else Vector2(move_direction.x, 0))

func is_close_to_target(current_target: Vector2) -> bool:
	var distance = character_body.global_position.distance_to(current_target)
	return distance < (35 if is_aggro else 2)

func calculate_directions(current_target: Vector2):
	look_direction = -1 if character_body.global_position.x > current_target.x else 1
	move_direction = character_body.global_position.direction_to(current_target).normalized()

func calculate_target() -> Vector2: 
	var current_target = player_body.global_position if is_aggro else target.global_position
	if not wait_timer.is_stopped():
		current_target = wait_pos
	return current_target
		
func calculate_gravity(delta: float):
	if not character_body.is_on_floor() and gravity > 0:
		current_gravity += gravity * delta
	elif gravity > 0:
		current_gravity = 0
	character_body.velocity.y += current_gravity

func damage():
	health -= 1
	if health <= 0:
		fainted = true
		gravity = 1000
		sprite_node.flip_v = true
	
func check_if_stuck(delta: float):
	if not is_aggro and movement_mode != MoveMode.None and character_body.velocity.length() == 0:
		stuck_timer += delta
		if stuck_timer > 3:
			stuck_timer = 0
			reset_target_to_random(true)
	else:
		stuck_timer = 0
		
func reset_target_to_random(stuck: bool):
	if(calculate_target() == wait_pos):
		return
			
	if not stuck:
		target.global_position.x = target.global_position.x + (patrol_distance * look_direction * -1)
	else:
		target.global_position.x = character_body.global_position.x + (patrol_distance / 2 * look_direction * -1)
	#print("Character: ", character_body.global_position.x, " : Target: ", target.global_position.x)

func player_entered(body: Node2D) -> void:
	if attack_mode == AttackMode.Passive or (attack_mode == AttackMode.Neutral and not is_neutral_and_attacked):
		return
	is_aggro = true
	player_body = body
	wait_timer.stop()

func player_left(body: Node2D) -> void:
	if attack_mode == AttackMode.Passive or (attack_mode == AttackMode.Neutral and not is_neutral_and_attacked):
		return
	is_aggro = false
	target.global_position.x = character_body.global_position.x
	reset_target_to_random(false)
	wait_timer.start()
	wait_pos = character_body.global_position
