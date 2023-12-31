extends SpecialLevelBase
class_name CutScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# func _on_cutscene_timer_timeout() -> void:
# 	var cutscene = preload("res://special_levels/cutscene_vedal.tscn").instantiate()
# 	cutscene.play("sequence")
# 	add_child(cutscene)
# 	cutscene.get_node("Camera2D").make_current()
# 	pass # Replace with function body.
