extends Node

@export var item_scene: PackedScene

# Metadata
var tilemap_size
var tilemap_scale
var screen_size

# Game variables
var score = 0
var items_to_collect: Array[Node] = []

# TODO: maybe need state manager? but it's a jam, so I'll just leave a note


func ready_up_camera():
	$Camera2D.set_position(Vector2(0, 0))
	var larger_scale = max(
		screen_size.x / float(tilemap_scale.x * tilemap_size.x),
		screen_size.y / float(tilemap_scale.y * tilemap_size.y)
	)
	$Camera2D.set_zoom(Vector2(larger_scale, larger_scale))
	#$Camera2D.set_limit(
	#	Rect2(0, 0, $TileMap.get_used_rect().size.x, $TileMap.get_used_rect().size.y))
	$Camera2D.make_current()


func level_begin():
	# This function should be called as part of the callback to the timer.
	# Signifies the beginning of the contallable game
	$Player.keys_disabled = false
	$Player.reset_camera_view()
	for item in items_to_collect:
		item.hide()


func pan_entire_world():
	# sets up a one shot timer, allow the user to interact with the camera to look around for 5 seconds
	$Player.keys_disabled = true
	var timer = Timer.new()
	add_child(timer)

	timer.wait_time = 5.0
	timer.one_shot = true
	timer.start()
	ready_up_camera()
	timer.timeout.connect(level_begin)


# Called when the node enters the scene tree for the first time.
# TODO: need to multiple with tile size as well, hopefully the fact that I put a TODO means I will remember clueless
# TODO: add camera limit probably
func _ready():
	screen_size = get_viewport().size
	tilemap_size = $TileMap.get_used_rect().size

	# calculates the full scale. there is probably a correct way to do tiles, but i'm dumb
	tilemap_scale = $TileMap.tile_set.tile_size
	tilemap_scale.x *= $TileMap.scale.x
	tilemap_scale.y *= $TileMap.scale.y
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_score():
	score += 1
	$UI.update_score(score)


func reset():
	for n in 10:
		var item_position = Vector2(
			randf_range(0, tilemap_size.x * tilemap_scale.x),
			randf_range(0, tilemap_size.y * tilemap_scale.y)
		)
		var item_instance = item_scene.instantiate()
		item_instance.position = item_position
		add_child(item_instance)
		item_instance.collected.connect(update_score)
		items_to_collect.append(item_instance)

	pan_entire_world()

	# HACK+debug: make player the enemy follower target
	$MeleeEnemy.target = $Player
