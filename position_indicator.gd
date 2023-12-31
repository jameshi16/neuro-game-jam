extends Control

@export var texture: Texture
@export var label: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.texture = texture
	$Label.text = label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
