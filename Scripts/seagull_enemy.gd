extends Enemy

enum SwoopStage { BeforeSwoop, SwoopDown, SwoopUp }

var is_swooping: bool = false
var before_swooping_point: Vector2 = Vector2.ZERO
var swooping_point: Vector2 = Vector2.ZERO
var swoop_stage: SwoopStage = SwoopStage.BeforeSwoop

func calculate_target() -> Vector2: 
	if not is_swooping and is_aggro:
		is_swooping = true
		before_swooping_point = character_body.global_position
		swooping_point = player_body.global_position
		swoop_stage = SwoopStage.BeforeSwoop
		wait_timer.start()
	
	if is_swooping:
		if swoop_stage == SwoopStage.BeforeSwoop:
			if wait_timer.is_stopped():
				swoop_stage = SwoopStage.SwoopDown
			else:
				return before_swooping_point
				
		if swoop_stage == SwoopStage.SwoopDown:
			sprite_node.look_at(swooping_point)
			return swooping_point
		
		if swoop_stage == SwoopStage.SwoopUp:
			var diff = swooping_point.x - before_swooping_point.x
			var target = Vector2(before_swooping_point.x + (diff * 2), before_swooping_point.y)
			sprite_node.look_at(target)
			return target
			
	return super.calculate_target()

func determine_sprite_flip() -> Vector2:
	if is_swooping and not swoop_stage == SwoopStage.BeforeSwoop:
		return Vector2(0, look_direction == -1)
	return super.determine_sprite_flip()
	

func calculate_velocity() -> Vector2:
	return (chase_speed if is_swooping and not swoop_stage == SwoopStage.BeforeSwoop else speed) * move_direction

func is_close_to_target(current_target: Vector2) -> bool:
	var is_close = character_body.global_position.distance_to(current_target) < 2
	if is_swooping and is_close:
		if swoop_stage == SwoopStage.SwoopDown:
			swoop_stage = SwoopStage.SwoopUp
		elif swoop_stage == SwoopStage.SwoopUp:
			is_swooping = false
			sprite_node.look_at(sprite_node.global_position + Vector2(10, 0))
			reset_target_to_random(true)
	return is_close
