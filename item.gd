extends Area2D

signal collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body:Node2D) -> void:
	if body.name != 'Player':
		return

	hide()
	collected.emit()
	queue_free()
	$CollisionShape2D.set_deferred("disabled", true)
