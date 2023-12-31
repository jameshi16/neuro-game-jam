extends SpecialLevelBase

const Balloon = preload("res://dialogue/balloon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(func(_not_used) : level_completed.emit())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body:Node2D) -> void:
	if body is Player:
		hud.hide()
		player.keys_disabled = true
		player.get_node("AnimatedSprite2D").play("idle_up")
		var balloon = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://dialogue/special_levels.dialogue"), "evil")
