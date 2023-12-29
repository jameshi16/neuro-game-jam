extends Area2D
signal hit
signal player_died

# add a variable that adjusts speed

@export var default_speed = 400
@export var sprint_mod = 2
@export var default_health = 100
@export var knockback_speed = 3000
var screen_size
var keys_disabled = true
var speed = default_speed
var health = default_health
var acceleration = Vector2.ZERO


func process_keys(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		if Input.is_action_pressed("sprint"):
			velocity *= sprint_mod
			$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	# TODO: We need to correctly obtain the world boundary. Likely need to do it via the tilemap or something
	# position = position.clamp(Vector2.ZERO, screen_size)


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !keys_disabled:
		process_keys(delta)
	check_game_over()

	# any leftover acceleration (possibly from knockbacks)
	position += acceleration * delta


func _on_body_entered(_body: Node2D):
	# TODO: Probably should flash because damaged
	hit.emit()


func reset_camera_view():
	$Camera2D.make_current()


func reset(pos):
	acceleration = Vector2(0, 0)
	reset_camera_view()
	position = pos
	show()
	speed = default_speed
	health = default_health
	$CollisionShape2D.disabled = false


func check_game_over():
	if health <= 0:
		keys_disabled = true
		$KnockbackTimer.stop()
		player_died.emit()
		# reset(Vector2(0, 0))


func knockback(enemy_pos: Vector2):
	# inverse enemy position and then normalize
	var velocity = (position - enemy_pos).normalized() * knockback_speed
	# start a timer for 500ms, move the player in the direction of the above vector
	keys_disabled = true
	# position += velocity
	acceleration = velocity
	$KnockbackTimer.start()


func _on_area_shape_entered(
	area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int
):
	if area is MeleeEnemy:
		health -= 10
		knockback(area.position)
		hit.emit()
	pass  # Replace with function body.


func _on_knockback_timer_timeout():
	# TODO: clarivoyant: will cause trouble if player is damaged from the start (also for acceleration, any number of objects everywhere else can modify it)
	# solution 1: use a state manager like a sane person
	# solution 2: ZA WORLDO, enemies shouldn't be moving during the worldview anyway
	keys_disabled = false
	acceleration = Vector2(0, 0)
	# pass # Replace with function body.
