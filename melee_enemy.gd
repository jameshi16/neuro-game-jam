extends "res://enemy.gd"
class_name MeleeEnemy


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body:Node) -> void:
	print(body)
	if body is Player:
		body.hit.emit()
		body.knockback(position)
	pass # Replace with function body.
