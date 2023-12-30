extends Shovel
class_name NormalShovel

var radius = 100

func _init(player_: Player, shovel_timer_: Timer):
	super._init(player_, shovel_timer_)
	attack_scene = preload("res://slash.tscn")
	cooldown_timer_duration = 0.5
	stamina = 50
	damage = 10

func _on_attack_connected(node: Node):
	attack_landed.emit(node)

func attack(direction: Vector2):
	if !cooldown_timer.is_stopped() or player.stamina < stamina:
		return

	player.update_stamina(player.stamina - stamina)
	var relative_position = direction.normalized()
	var slash_node = preload("res://slash.tscn")
	var attack_node = slash_node.instantiate()
	attack_node.position = direction + (relative_position * radius)
	attack_node.rotation = relative_position.angle()
	attack_node.body_entered.connect(_on_attack_connected)
	player.add_child(attack_node)
	cooldown_timer.start()

func apply_shovel_effects_on_enemy(enemy: Enemy):
	enemy.receive_damage(damage)
	enemy.knockback(player.position, 800)
