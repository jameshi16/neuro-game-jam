extends Shovel
class_name NormalShovel

var radius = 100

func _init(player_: Player, shovel_timer_: Timer):
	super._init(player_, shovel_timer_)
	attack_scene = preload("res://slash.tscn")
	cooldown_timer_duration = 2.0

func _on_attack_connected(node: Node):
	attack_landed.emit(node)


func attack(direction: Vector2):
	if !cooldown_timer.is_stopped():
		return

	var relative_position = direction.normalized()
	var slash_node = preload("res://slash.tscn")
	var attack_node = slash_node.instantiate()
	attack_node.position = direction + (relative_position * radius)
	attack_node.rotation = relative_position.angle()
	attack_node.body_entered.connect(_on_attack_connected)
	player.add_child(attack_node)
	cooldown_timer.start()
