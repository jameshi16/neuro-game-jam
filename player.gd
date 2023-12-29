extends Area2D
signal hit

# add a variable that adjusts speed

@export var speed = 400
@export var sprint_mod = 2
var screen_size
var keys_disabled = true

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


func _on_body_entered(_body: Node2D):
	# TODO: Probably should flash because damaged
	hit.emit()

func reset_camera_view():
	$Camera2D.make_current()

func reset(pos):
	reset_camera_view()
	position = pos
	show()
	$CollisionShape2D.disabled = false
