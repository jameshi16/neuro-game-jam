extends CharacterBody2D
class_name Enemy

@export var speed = 100
@export var health = 100

var target: Node
var acceleration: Vector2 = Vector2.ZERO
var invincible = false
var physics_enabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.max_value = health
	$HealthBar.value = health


func _physics_process(delta):
	if !physics_enabled:
		return

	if target:
		var direction = $NavigationAgent2D.get_next_path_position()
		var collision = move_and_collide((direction - position).normalized() * speed * delta)
		if collision and collision.get_collider() is Player:
			var player: Player = collision.get_collider()
			player.enemy_damages_player(self)

	move_and_collide(acceleration * delta)


func set_navigation_map(navigation_map: RID):
	# Godot literally doesn't say it defaults to the background layer by default, I am very madge
	$NavigationAgent2D.set_navigation_map(navigation_map)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_navigation_timer_timeout() -> void:
	if target:
		$NavigationAgent2D.target_position = target.position

func knockback(reference_pos: Vector2, knockback_speed: float):
	if invincible:
		return

	var vel = (position - reference_pos).normalized() * knockback_speed
	acceleration = vel
	$KnockbackTimer.start()
	$InvincibilityTimer.start()
	invincible = true

func receive_damage(damage: int) -> void:
	if invincible:
		return

	health -= damage
	if health <= 0:
		queue_free()
	$HealthBar.value = health

func _on_knockback_timer_timeout() -> void:
	acceleration = Vector2.ZERO

func _on_invincibility_timer_timeout() -> void:
	invincible = false
