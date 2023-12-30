extends Node

@export var item_scene: PackedScene
@export var enemies: Array[PackedScene]

# TODO: make these take in names instead so that i can reduce future programmer error
@export var terrain_set: int = 0
@export var terrain: int = 0
@export var generation_steps: int = 2000
@export var turning_steps = 8
@export var turn_early_probability = 0.02
@export var map_size_x = 50
@export var map_size_y = 20
@export var navigation_layer = 0
@export var num_enemies = 5
@export var num_items = 10

# Metadata
var tilemap_size
var tilemap_scale
var screen_size
var restart_cooling_down = true

# Game variables
var score = 0
var items_to_collect: Array[Item] = []
var enemies_in_scene: Array[Enemy] = []

# TODO: maybe need state manager? but it's a jam, so I'll just leave a note


func ready_up_camera():
	$Camera2D.set_position(Vector2(0, 0))
	var larger_scale = min(
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
	$Player.keys_disabled = true

	$WorldPanTimer.start()
	ready_up_camera()
	$WorldPanTimer.timeout.connect(level_begin)


# Called when the node enters the scene tree for the first time.
# TODO: need to multiple with tile size as well, hopefully the fact that I put a TODO means I will remember clueless
# TODO: add camera limit probably
func _ready():
	LevelGenerator.turning_steps = turning_steps
	LevelGenerator.turn_early_probability = turn_early_probability

	screen_size = get_viewport().size
	# NOTE: This was for fixed tilemaps
	# tilemap_size = $TileMap.get_used_rect().size
	# tilemap_size = Vector2(800, 600)
	tilemap_size = Vector2(map_size_x, map_size_y)

	# calculates the full scale. there is probably a correct way to do tiles, but i'm dumb
	tilemap_scale = $TileMap.tile_set.tile_size
	tilemap_scale.x *= $TileMap.scale.x
	tilemap_scale.y *= $TileMap.scale.y
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !restart_cooling_down and Input.is_action_pressed("restart_level"):
		reset()


func update_score(item: Item):
	score += item.worth_to_score[item.worth]
	items_to_collect.erase(item)
	$UI.update_score(score)


func fill_with_with_collision_tiles():
	for i in tilemap_size.x + 2:
		for j in tilemap_size.y + 2:
			$TileMap.set_cell(navigation_layer, Vector2(i - 1, j - 1), 0, Vector2(0, 0))


func spawn_mobs(locations: Array):
	var navmap = $TileMap.get_navigation_map(navigation_layer)
	for location in locations:
		var enemy = enemies.pick_random().instantiate()
		enemy.position = Vector2(
			(location.x + 0.5) * tilemap_scale.x, (location.y + 0.5) * tilemap_scale.y
		)
		add_child(enemy)
		enemy.target = $Player
		enemy.set_navigation_map(navmap)
		enemies_in_scene.append(enemy)


func spawn_items(locations: Array):
	for location in locations:
		var item_instance = item_scene.instantiate()
		item_instance.position = Vector2(
			(location.x + 0.5) * tilemap_scale.x, (location.y + 0.5) * tilemap_scale.y
		)
		add_child(item_instance)
		item_instance.collected.connect(update_score)
		items_to_collect.append(item_instance)


func free_items():
	for item in items_to_collect:
		item.queue_free()
	items_to_collect = []


func free_enemies():
	for enemy in enemies_in_scene:
		enemy.queue_free()
	enemies_in_scene = []


func reset():
	# generate a world here (TODO: tilemap_size is a temporary size)
	var bounding_box = Rect2(Vector2(0, 0), tilemap_size)
	var start_pos = Vector2(randi() % roundi(tilemap_size.x), randi() % roundi(tilemap_size.y))

	var global_pos = Vector2(
		(start_pos.x + 0.5) * tilemap_scale.x, (start_pos.y + 0.5) * tilemap_scale.y
	)

	free_items()
	free_enemies()
	$Player.reset(global_pos)
	score = 0
	$UI.update_health(100)

	var level_gen = LevelGenerator.new(start_pos, bounding_box, generation_steps)
	var path = level_gen.generate_level()

	# fill with the collision tiles first
	fill_with_with_collision_tiles()
	$TileMap.set_cells_terrain_connect(navigation_layer, path, terrain_set, terrain, false)

	var item_locations = path.duplicate()
	item_locations.shuffle()
	spawn_items(item_locations.slice(0, num_items))

	var mob_locations = path.duplicate()
	mob_locations.shuffle()
	spawn_mobs(mob_locations.slice(0, num_enemies))

	pan_entire_world()
	restart_cooling_down = true
	$RestartCooldownTimer.start()


func _on_player_hit():
	$UI.update_health($Player.health)


func _on_player_player_died():
	reset()


func _on_restart_cooldown_timer_timeout() -> void:
	restart_cooling_down = false


func _on_world_pan_timer_timeout() -> void:
	level_begin()


func _on_player_stamina_changed() -> void:
	$UI.update_stamina($Player.stamina)
