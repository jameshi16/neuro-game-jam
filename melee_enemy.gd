extends Enemy
class_name MeleeEnemy


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


func _physics_process(delta):
	super._physics_process(delta)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.hit.emit()
		body.knockback(position)
