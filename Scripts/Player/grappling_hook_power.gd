extends Power
class_name GrapplingHookPower

var grappling: bool = false
var grapple_point: Vector2 = Vector2.ZERO
var pulling_enemy: bool = false
var pulled_enemy: Node2D = null
var hooked_collider: CollisionShape2D = null
var hook = null


const MAX_ROPE_LENGTH := 300.0
const SWING_FORCE := 3000.0
const PULL_SPEED := 3
var rope_length = 0 

var sprite_active = preload("res://Assets/Sprites/Characters/Peppers/spr_green_pepper_test_active.png")
var sprite = preload("res://Assets/Sprites/Characters/Peppers/spr_green_pepper_test.png")

func _init():
	id = "grappling_hook"
	texture = preload("res://Assets/Sprites/Characters/Peppers/spr_green_pepper_test.png")
	text = "Current Power: Grappling Hook"

func use(companion):
	if pulling_enemy:
		_stop_pulling_enemy(companion)
		companion.get_node("GFX").texture = sprite
		return
	companion.get_node("GFX").texture = sprite_active
	#var enemy = companion._find_nearest_in_group("pullable", companion.PLUG_RANGE)
	hook = companion._find_nearest_in_group("hookable", companion.PLUG_RANGE)
	#if enemy and (not hook and companion.player_body.global_position.distance_to(enemy.global_position) < companion.player_body.global_position.distance_to(hook.global_position)):
	#	_start_pulling_enemy(companion, enemy)
	#	print(enemy)
	#	return
	if hook:
		# increase max speed well grappling
		companion.player_body.friction = 0
		companion.player_body.grappling = true
		companion.raycast.target_position = hook.global_position - companion.player_body.global_position
		companion.raycast.force_raycast_update()
		var collider = companion.raycast.get_collider()
		if not collider or collider == hook:
			grapple_point = hook.global_position
			grappling = true
			hooked_collider = hook.get_node_or_null("CollisionShape2D")
			if hooked_collider:
				hooked_collider.disabled = true
			


func update(companion, delta):
	if grappling:
		_update_grapple(companion, delta)
		
	elif pulling_enemy:
		_update_enemy_pull(companion, delta)


func _update_grapple(companion, delta):
	grapple_point = hook.global_position
	var player = companion.player_body
	companion.global_position = player.global_position
	var player_pos = player.global_position
	var rope_vec = grapple_point - player_pos
	var distance = rope_vec.length()
	if distance > MAX_ROPE_LENGTH:
		_stop_grapple(companion)
		return
	var rope_dir = rope_vec.normalized()
	var tangent = Vector2(-rope_dir.y, rope_dir.x)
	var tangential_speed = player.velocity.dot(tangent)
	player.velocity = tangent * tangential_speed 
	var gravity_tangential = Vector2(0, player.gravity/2).dot(tangent)
	if Input.is_action_pressed("move_left"):
		if player.is_on_floor():
			player.velocity -= tangent * SWING_FORCE * delta 
	if Input.is_action_pressed("move_right"):
		if player.is_on_floor():
			player.velocity += tangent * SWING_FORCE * delta
	if Input.is_action_pressed("move_up") and player.position.distance_to(grapple_point) > 50:
		player.velocity += (grapple_point - player.position).normalized()*SWING_FORCE*delta*PULL_SPEED
	if Input.is_action_pressed("move_down"):
		player.velocity += -(grapple_point - player.position).normalized()*SWING_FORCE*delta*PULL_SPEED
	# Make the player not fall if they're just hanigng on tothe grapple
	#if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		#player.velocity.y -= player.gravity*delta

	player.velocity += (grapple_point - player.position).normalized()*delta*player.gravity
	player.global_position = grapple_point - rope_dir * distance

	companion.plug.clear_points()
	companion.plug.add_point(companion.plug.to_local(companion.global_position))
	companion.plug.add_point(companion.plug.to_local(grapple_point))
	companion.rotation = rope_vec.angle() + PI + 1.5
	companion.plug_head.global_position = grapple_point
	companion.plug_head.rotation = rope_vec.angle()
	companion.plug_head.show()

	
	if Input.is_action_just_pressed("pepper_power") or Input.is_action_just_pressed("jump"):
		companion.get_node("GFX").texture = sprite
		_stop_grapple(companion)
		player.get_node("Timers/CompanionCooldown").start()
		
		# "Swing off" releasing the grapple
		player.velocity *= 2.5
	
		
	

func _start_pulling_enemy(_companion, enemy: Node2D):
	pulled_enemy = enemy
	#pulled_enemy.grappled = true
	pulling_enemy = true


func _update_enemy_pull(companion, delta):
	#if pulled_enemy.test_move(pulled_enemy.transform, Vector2.ZERO) or pulled_enemy.global_position.distance_to(companion.player_body.global_position) < 40:
		#_stop_pulling_enemy(companion)
		#companion.get_node("GFX").texture = sprite
		#return
	var dir = (companion.global_position - pulled_enemy.global_position).normalized()
	pulled_enemy.global_position += dir * companion.ENEMY_PULL_SPEED * delta
	companion.plug.clear_points()
	companion.plug.add_point(companion.plug.to_local(companion.global_position))
	companion.plug.add_point(companion.plug.to_local(pulled_enemy.global_position))
	companion.rotation = (pulled_enemy.global_position - companion.global_position).angle() + PI + 1.5
	companion.plug_head.global_position = pulled_enemy.global_position
	companion.plug_head.rotation = (pulled_enemy.global_position - companion.global_position).angle()
	companion.plug_head.show()
	grapple_point = pulled_enemy.position



func _stop_pulling_enemy(companion):
	pulling_enemy = false
	if pulled_enemy:
		#pulled_enemy.grappled = false
		#pulled_enemy.start_x = pulled_enemy.global_position.x
		pulled_enemy = null
	companion.plug.clear_points()
	companion.plug_head.hide()
	companion.rotation = 0

func _stop_grapple(companion):
	grappling = false
	companion.rotation = 0
	companion.plug.clear_points()
	companion.plug_head.hide()
	if hooked_collider:
		hooked_collider.disabled = false
		hooked_collider = null
	# Reset friction
	companion.player_body.friction = 0.15
	companion.player_body.grappling = false


func on_deselect(companion):
	_stop_pulling_enemy(companion)
	_stop_grapple(companion)
