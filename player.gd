extends CharacterBody2D
class_name Player
signal hit
signal player_died

# add a variable that adjusts speed

@export var default_speed = 400
@export var sprint_mod = 2
@export var default_health = 100
@export var knockback_speed = 2000
var screen_size
var keys_disabled = true
var speed = default_speed
var health = default_health
var acceleration = Vector2(0, 0)
var invincible = false


func process_keys(delta):
	var vel = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	if Input.is_action_pressed("move_down"):
		vel.y += 1

	if vel.length() > 0:
		vel = vel.normalized() * speed
		if Input.is_action_pressed("sprint"):
			vel *= sprint_mod
			$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.stop()

	move_and_collide(vel * delta)
	# TODO: We need to correctly obtain the world boundary. Likely need to do it via the tilemap or something
	# position = position.clamp(Vector2.ZERO, screen_size)


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_game_over()

func _physics_process(delta):
	if !keys_disabled:
		process_keys(delta)
	move_and_collide(acceleration * delta)

func reset_camera_view():
	$Camera2D.make_current()

func reset(pos):
	stop_every_timer()
	reset_camera_view()
	position = pos
	acceleration = Vector2(0, 0)
	show()
	speed = default_speed
	health = default_health
	$CollisionShape2D.disabled = false
	invincible = false

func check_game_over():
	if health <= 0:
		keys_disabled = true
		stop_every_timer()
		player_died.emit()

func stop_every_timer():
	$KnockbackTimer.stop()
	$InvincibilityTimer.stop()

func enemy_damages_player(enemy: Enemy):
	if invincible:
		return
	health -= 10
	hit.emit()
	knockback(enemy.position)

func knockback(enemy_pos: Vector2):
	# inverse enemy position and then normalize
	var vel = (position - enemy_pos).normalized() * knockback_speed
	keys_disabled = true
	acceleration = vel
	$KnockbackTimer.start()
	trigger_invincibility()

func trigger_invincibility():
	$InvincibilityTimer.start()
	invincible = true


func _on_knockback_timer_timeout():
	# TODO: clarivoyant: will cause trouble if player is damaged from the start (also for acceleration, any number of objects everywhere else can modify it)
	# solution 1: use a state manager like a sane person
	# solution 2: ZA WORLDO, enemies shouldn't be moving during the worldview anyway
	keys_disabled = false
	acceleration = Vector2(0, 0)


func _on_invincibility_timer_timeout() -> void:
	invincible = false
