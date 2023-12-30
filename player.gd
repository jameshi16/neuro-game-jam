extends CharacterBody2D
class_name Player
signal hit
signal player_died
signal stamina_changed

# add a variable that adjusts speed

@export var default_speed = 400
@export var default_health = 100
@export var default_stamina = 100
@export var sprint_mod = 2
@export var knockback_speed = 2000
@export var stamina_consumption_rate = 2
@export var stamina_recovery_rate = 1
@export var sprinting_stamina_consumption_mod = 1.0
@export var digging_stamina_consumption_mod = 0.05
var screen_size
var keys_disabled = true
var digging = false
var speed = default_speed
var health = default_health
var stamina = default_stamina
var acceleration = Vector2(0, 0)
var invincible = false

var items_in_contact: Array[Item] = []


# returns true if movement
func process_keys(_delta):
	var vel = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	if Input.is_action_pressed("move_down"):
		vel.y += 1

	var new_stamina = stamina
	if vel.length() > 0:
		vel = vel.normalized() * speed
		if new_stamina > 0 and Input.is_action_pressed("sprint"):
			vel *= sprint_mod
			$AnimatedSprite2D.play("idle")
			new_stamina -= stamina_consumption_rate * sprinting_stamina_consumption_mod
	else:
		$AnimatedSprite2D.stop()

	# if !Input.is_action_pressed("sprint"): (i think it's nice to have constant recovery)
	new_stamina += stamina_recovery_rate

	if stamina != new_stamina:
		update_stamina(new_stamina)

	velocity = vel
	move_and_slide()


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_game_over()


func update_stamina(new_stamina: float):
	stamina = clamp(new_stamina, 0, default_stamina)
	stamina_changed.emit()


func attempt_digging():
	if !keys_disabled and Input.is_action_pressed("accept") and !digging:
		$DiggingTimer.start()
		$DiggingProgressTimer.start()
		$DiggingProgressBar.value = 0
		$DiggingProgressBar.max_value = $DiggingTimer.wait_time
		$DiggingProgressBar.show()
		digging = true
	elif keys_disabled or !Input.is_action_pressed("accept") or stamina <= 0:
		$DiggingTimer.stop()
		$DiggingProgressTimer.stop()
		$DiggingProgressBar.hide()
		digging = false

	if digging:
		update_stamina(stamina - stamina_consumption_rate * digging_stamina_consumption_mod)


func _physics_process(delta):
	attempt_digging()
	if !keys_disabled and !digging:
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
	stamina = default_stamina
	$CollisionShape2D.disabled = false
	invincible = false

	# this shouldn't be needed, but just in case
	items_in_contact = []


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


func _on_diggable_detector_area_shape_entered(
	_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int
) -> void:
	if area is Item:
		items_in_contact.append(area)


func _on_diggable_detector_area_shape_exited(
	_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int
) -> void:
	if area is Item:
		items_in_contact.erase(area)


func _on_digging_timer_timeout() -> void:
	digging = false
	for item in items_in_contact:
		item.collect()


func _on_digging_progress_timer_timeout() -> void:
	$DiggingProgressBar.value += 0.1
