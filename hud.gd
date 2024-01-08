extends CanvasLayer
class_name HUD


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# TODO: Actually, I can probably use setters for these. Leaving a TODO here surely means I will address it clueless


func update_score(score: int):
	$Score.text = "Score: %d" % score


func update_health(health: int):
	$Health.text = "Health: %d" % health
	$HealthBar.value = health


func update_stamina(stamina: int):
	$Stamina.text = "Stamina: %d" % stamina
	$StaminaBar.value = stamina

func update_time(time: int):
	$Time.text = "Time Left: %d" % time

func hide_timer():
	$Time.hide()

func show_timer():
	$Time.show()
