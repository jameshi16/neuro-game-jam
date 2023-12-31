extends TileMap
class_name SpecialLevelBase

signal item_picked
signal level_completed

var player
var hud

func initialize_from_main(main_player: Player, main_hud: HUD):
	player = main_player
	hud = main_hud

func level_began():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
