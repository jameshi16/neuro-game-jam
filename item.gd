extends Area2D

signal collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.name != 'Player':
		return

	hide()
	collected.emit()
	queue_free()
	$CollisionShape2D.set_deferred("disabled", true)
