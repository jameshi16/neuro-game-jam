class_name Shovel

signal attack_landed(node: Node)

var attack_scene: PackedScene
var cooldown_timer_duration: float = 2.0 :
	set(value):
		cooldown_timer.wait_time = value

var cooldown_timer: Timer
var player: Player
var damage = 1
var stamina = 20

func _init(player_ : Player, shovel_timer_: Timer):
	player = player_
	cooldown_timer = shovel_timer_
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown_timer_duration

# returns true if an attack was performed
func attack(_direction: Vector2):
	pass

func apply_shovel_effects_on_enemy(_enemy: Enemy):
	pass
