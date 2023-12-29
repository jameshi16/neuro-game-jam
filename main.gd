extends Node

@export var item_scene: PackedScene
var tilemap_size
var tilemap_scale
var screen_size

func ready_up_camera():
	# Sets the camera view to the whole world, then sets the current viewpoint camera
	$Camera2D.set_position(Vector2(0, 0))
	$Camera2D.set_zoom(Vector2(
		screen_size.x / float(tilemap_scale.x * tilemap_size.x),
		screen_size.y / float(tilemap_scale.y * tilemap_size.y)))
	# $Camera2D.set_limit(Rect2(0, 0, $TileMap.get_used_rect().size.x, $TileMap.get_used_rect().size.y))
	$Camera2D.make_current()


# Called when the node enters the scene tree for the first time.
# TODO: need to multiple with tile size as well, hopefully the fact that I put a TODO means I will remember clueless
# TODO: add camera limit probably
func _ready():
	screen_size = get_viewport().size
	print(screen_size)
	tilemap_size = $TileMap.get_used_rect().size

	# calculates the full scale. there is probably a correct way to do tiles, but like clueless
	tilemap_scale = $TileMap.tile_set.tile_size
	tilemap_scale.x *= $TileMap.scale.x
	tilemap_scale.y *= $TileMap.scale.y
	for n in 10:
		var item_position = Vector2(
			randf_range(0, tilemap_size.x * tilemap_scale.x),
			randf_range(0, tilemap_size.y * tilemap_scale.y)
			)
		var item_instance = item_scene.instantiate()
		item_instance.position = item_position
		add_child(item_instance)

	ready_up_camera()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
