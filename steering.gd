extends Object
class_name Steering


# Follows the player in a linear fashion
static func follow_linear(self_pos: Node, target_pos: Vector2, speed: int, delta):
	var dx = target_pos.x - self_pos.position.x;
	var dy = target_pos.y - self_pos.position.y;
	var dist = sqrt(dx * dx + dy * dy);

	self_pos.position.x += dx / dist * speed * delta;
	self_pos.position.y += dy / dist * speed * delta
