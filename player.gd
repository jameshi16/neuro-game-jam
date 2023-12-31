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
var current_hflip = false
var current_animation_suffix = 'down'
@onready var shovel: Shovel = NormalShovel.new(self, $ShovelTimer)

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

	# TODO: Deprecated block clueless
	# it's possible for all buttons to be pressed. so, we do a big
	# brain move and use the vector to figure out what animation to
	# play (it's not possible to be up and down at the same time if we think in vectors)
	# var animation_composition = []
	# if vel.y < 0:
	# 	animation_composition.append("up")
	# if vel.y > 0:
	# 	animation_composition.append("down")
	# if vel.x < 0:
	# 	animation_composition.append("side")
	# 	current_hflip = true
	# if vel.x > 0:
	# 	animation_composition.append("side")
	# 	current_hflip = false

	# var new_animation_composition = "_".join(animation_composition)
	# if new_animation_composition != '':
	# 	current_animation_composition = new_animation_composition
	# $AnimationPlayer.play(current_animation_composition)

	var new_animation_prefix = 'idle'
	var new_animation_suffix = current_animation_suffix
	var new_hflip = current_hflip
	if vel.x < 0:
		new_animation_suffix = 'side'
		new_hflip = true
	if vel.x > 0:
		new_animation_suffix = 'side'
		new_hflip = false
	if vel.y < 0:
		new_animation_suffix = 'up'
	if vel.y > 0:
		new_animation_suffix = 'down'

	var new_stamina = stamina
	if vel.length() > 0:
		new_animation_prefix = 'walk'
		vel = vel.normalized() * speed
		if new_stamina > 0 and Input.is_action_pressed("sprint"):
			vel *= sprint_mod
			# $AnimatedSprite2D.play("idle_up")
			# $AnimatedSprite2D.play("idle")
			new_stamina -= stamina_consumption_rate * sprinting_stamina_consumption_mod

	$AnimatedSprite2D.play('_'.join([new_animation_prefix, new_animation_suffix]))
	$AnimatedSprite2D.flip_h = new_hflip

	current_hflip = new_hflip
	current_animation_suffix = new_animation_suffix

	# stamina regen shouldn't happen if we're cooling down from a shovel attack
	# or digging
	# or holding sprint
	if !Input.is_action_pressed("sprint") and !digging and shovel.cooldown_timer.is_stopped():
		new_stamina += stamina_recovery_rate

	if stamina != new_stamina:
		update_stamina(new_stamina)

	velocity = vel
	move_and_slide()


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	shovel.attack_landed.connect(player_damages_node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


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
		$AnimatedSprite2D.play("dig")
		digging = true
	elif keys_disabled or !Input.is_action_pressed("accept") or stamina <= 0:
		$DiggingTimer.stop()
		$DiggingProgressTimer.stop()
		$DiggingProgressBar.hide()
		if $AnimatedSprite2D.animation == "dig":
			$AnimatedSprite2D.stop()
		digging = false

	if digging:
		update_stamina(stamina - stamina_consumption_rate * digging_stamina_consumption_mod)

func attempt_attack():
	if Input.is_action_pressed("attack") and stamina > 0:
		shovel.attack(get_local_mouse_position().normalized())


func _physics_process(delta):
	attempt_digging()
	if !keys_disabled and !digging:
		process_keys(delta)
		attempt_attack()
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


func player_damages_node(node: Node2D):
	if node is Enemy:
		var enemy: Enemy = node
		shovel.apply_shovel_effects_on_enemy(enemy)


func enemy_damages_player(enemy: Enemy):
	if invincible:
		return
	health -= 10
	hit.emit()
	knockback(enemy.position)
	check_game_over()


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
