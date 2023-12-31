extends Node
class_name Main

const Balloon = preload("res://dialogue/balloon.tscn")

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
@export var num_landmarks = 20

# Metadata
var tilemap_size
var tilemap_scale
var screen_size
var restart_cooling_down = true
var level_began = false

# Game variables
var items_to_collect: Array[Item] = []
var enemies_in_scene: Array[Enemy] = []
var current_special_level: SpecialLevelBase

# TODO: maybe need state manager? but it's a jam, so I'll just leave a note


func ready_up_camera():
	# NOTE: This is done like that because if I do Anchor Mode Top-Left, I will get spaces to the right
	var full_size = Vector2(tilemap_scale.x * tilemap_size.x, tilemap_scale.y * tilemap_size.y)
	if current_special_level: # special case for special levels because they're special
		var world_size = current_special_level.get_used_rect().size
		full_size = Vector2(world_size.x * tilemap_scale.x, world_size.y * tilemap_scale.y)
	var center = Vector2(full_size.x / 2, full_size.y / 2)
	$Camera2D.set_position(center)
	var larger_scale = min(
		screen_size.x / float(tilemap_scale.x * tilemap_size.x),
		screen_size.y / float(tilemap_scale.y * tilemap_size.y)
	)
	$Camera2D.set_zoom(Vector2(larger_scale, larger_scale))
	#$Camera2D.set_limit(
	#	Rect2(0, 0, $TileMap.get_used_rect().size.x, $TileMap.get_used_rect().size.y))
	$Camera2D.make_current()
	$UI.hide()
	$Camera2D.get_node("MapOverviewUI").show()


func level_begin():
	# This function should be called as part of the callback to the timer.
	# Signifies the beginning of the contallable game
	level_began = true
	$Player.get_node("PositionIndicator").hide()
	$Player.keys_disabled = false
	$Player.reset_camera_view()
	$UI.show()
	$Camera2D.get_node("MapOverviewUI").hide()
	if current_special_level:
		current_special_level.level_began()
		return

	for item in items_to_collect:
		item.hide()
		item.get_node("PositionIndicator").hide()

	for enemy in enemies_in_scene:
		enemy.physics_enabled = true
		enemy.get_node("PositionIndicator").hide()

	$MapTimer.start()


func pan_entire_world():
	$Player.keys_disabled = true
	ready_up_camera()


func load_fixed_level(scene: PackedScene):
	current_special_level = scene.instantiate()
	current_special_level.initialize_from_main($Player, $UI)
	current_special_level.item_picked.connect(update_score)
	current_special_level.level_completed.connect(reset)
	assert(current_special_level is SpecialLevelBase)
	add_child(current_special_level)
	$Player.reset(current_special_level.get_node("PlayerSpawnpoint").global_position)
	#$UI.get_node("Time").hide()
	# TODO: when level is cleared, this node should be removed


func select_level():
	clear_foreground_layer()
	clear_background_layer()
	# TODO: another useful case for state managers.
	# clueless

	# "Time left" will not be on the HUD if it is a special level

	if !State.cleared_tutorial:
		load_fixed_level(preload("res://special_levels/tutorial.tscn"))
		return

	if !State.visited_evil and State.fragments == 1:
		load_fixed_level(preload("res://special_levels/evil_level.tscn"))
		return

	if !State.visited_neuro and State.fragments == 3:
		load_fixed_level(preload("res://special_levels/neuro_level.tscn"))
		return

	if !State.visited_end and State.fragments == 6:
		load_fixed_level(preload("res://special_levels/hiyori_level.tscn"))
		return

	# generate a world here (TODO: tilemap_size is a temporary size)
	$UI.get_node("Time").show()
	current_special_level = null
	var bounding_box = Rect2(Vector2(0, 0), tilemap_size)
	var start_pos = Vector2(randi() % roundi(tilemap_size.x), randi() % roundi(tilemap_size.y))

	var global_pos = Vector2(
		(start_pos.x + 0.5) * tilemap_scale.x, (start_pos.y + 0.5) * tilemap_scale.y
	)
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

	var landmark_locations = path.duplicate()
	landmark_locations.shuffle()
	spawn_landmarks(landmark_locations.slice(0, num_landmarks))

	$Player.reset(global_pos)


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
	if !$GameOverTimer.is_stopped():
		return

	# special levels cannot be restarted
	if !restart_cooling_down and Input.is_action_pressed("restart_level") and !current_special_level:
		game_over(false)

	if !level_began and Input.is_action_just_pressed("start_level"):
		level_begin()

	# main only checks for random levels
	if !current_special_level:
		check_cleared()
		$UI.update_time($MapTimer.time_left)


func update_score(item: Item):
	State.score += item.worth_to_score[item.worth]
	items_to_collect.erase(item)
	$UI.update_score(State.score)


func clear_foreground_layer():
	for i in tilemap_size.x + 2:
		for j in tilemap_size.y + 2:
			$TileMap.set_cell(1, Vector2(i - 1, j - 1))

func clear_background_layer():
	for i in tilemap_size.x + 2:
		for j in tilemap_size.y + 2:
			$TileMap.set_cell(0, Vector2(i - 1, j - 1))

func fill_with_with_collision_tiles():
	for i in tilemap_size.x + 2:
		for j in tilemap_size.y + 2:
			$TileMap.set_cell(navigation_layer, Vector2(i - 1, j - 1), 0, Vector2(0, 0))

func is_pattern_overlapping_starting_location(location: Vector2, pattern: TileMapPattern) -> bool:
	var pattern_size = pattern.get_size()
	for i in pattern_size.x:
		for j in pattern_size.y:
			var tile_pos = Vector2(location.x + i, location.y + j)
			if $TileMap.get_cell_source_id(1, tile_pos) != -1 or \
				$TileMap.get_cell_source_id(0, tile_pos) == 0:
				return true
	return false

func apply_pattern_at_location(location: Vector2, pattern: TileMapPattern):
	var pattern_size = pattern.get_size()
	for i in pattern_size.x:
		for j in pattern_size.y:
			var p_coords = Vector2(i, j)
			if !pattern.has_cell(p_coords):
				continue

			var tile = pattern.get_cell_source_id(p_coords)
			var atlas = pattern.get_cell_atlas_coords(p_coords)
			var tile_pos = Vector2(location.x + i, location.y + j)
			$TileMap.set_cell(1, tile_pos, tile, atlas)


func spawn_landmarks(locations: Array):
	for location in locations:
		for n in 10: # try a maximum of 10 times
			var tileset = $TileMap.tile_set
			var pattern = tileset.get_pattern(randi() % tileset.get_patterns_count())

			if !is_pattern_overlapping_starting_location(location, pattern):
				apply_pattern_at_location(location, pattern)
				break


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
		enemy.dead.connect(_on_enemy_die)
		enemy.get_node("PositionIndicator").show()
		enemies_in_scene.append(enemy)


func spawn_items(locations: Array):
	for location in locations:
		var item_instance = item_scene.instantiate()
		item_instance.position = Vector2(
			(location.x + 0.5) * tilemap_scale.x, (location.y + 0.5) * tilemap_scale.y
		)
		item_instance.get_node("PositionIndicator").show()
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

func _on_note_balloon_complete(_not_used) -> void:
	print('done')
	DialogueManager.dialogue_ended.disconnect(_on_note_balloon_complete)
	game_over(false)

func read_note(note_id: int):
	$Player.hide()
	$UI.hide()
	restart_cooling_down = true
	DialogueManager.dialogue_ended.connect(_on_note_balloon_complete)
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://dialogue/special_levels.dialogue"), "note_%d" % note_id)

func game_over(lost: bool):
	$MapTimer.stop()
	clear_background_layer()
	clear_foreground_layer()

	free_enemies()
	if State.score / 10 > State.fragments and State.fragments < 6:
		State.fragments += 1
		read_note(State.fragments)
		return

	free_items()

	if lost:
		State.score = max(State.score - 10, 0)
		$UI.hide()
		$Camera2D.get_node("MapOverviewUI").hide()
		$GameOver.show()
		$GameOverTimer.start()
		return

	reset()

func check_cleared():
	if items_to_collect.size() == 0:
		game_over(false)


func reset():
	level_began = false
	$GameOver.hide()
	$UI.update_health(100)
	$UI.update_score(State.score)

	if current_special_level:
		current_special_level.queue_free()
		current_special_level = null

	select_level()

	# increase difficulty based on fragments collected
	num_enemies = 10 + State.fragments

	pan_entire_world()
	restart_cooling_down = true
	$MapTimer.stop()
	$RestartCooldownTimer.start()

	# Reset state of position indicators
	$Player.get_node("PositionIndicator").show()


func _on_player_hit():
	$UI.update_health($Player.health)


func _on_player_player_died():
	game_over(true)


func _on_restart_cooldown_timer_timeout() -> void:
	restart_cooling_down = false


func _on_player_stamina_changed() -> void:
	$UI.update_stamina($Player.stamina)

func _on_enemy_die(enemy: Enemy, defeat_score: float) -> void:
	State.score += defeat_score
	$UI.update_score(State.score)
	enemies_in_scene.erase(enemy)
	enemy.queue_free()

func _on_map_timer_timeout() -> void:
	game_over(false)

func _on_game_over_timer_timeout() -> void:
	reset()

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play()
