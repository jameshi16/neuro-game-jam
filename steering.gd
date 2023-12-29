class_name Steering


# Follows the player in a linear fashion
static func follow_linear(body: CharacterBody2D, target_pos: Vector2, speed: int, delta) -> KinematicCollision2D:
	var dx = target_pos.x - body.position.x;
	var dy = target_pos.y - body.position.y;
	var dist = sqrt(dx * dx + dy * dy);

	return body.move_and_collide(Vector2(dx / dist, dy / dist) * speed * delta)
