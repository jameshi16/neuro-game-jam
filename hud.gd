extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_score(score: int):
	$Score.text = "Score: %d" % score

func update_health(health: int):
	$Health.text = "Health: %d" % health
