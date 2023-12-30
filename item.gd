extends Area2D
class_name Item

signal collected

enum ItemWorth { LOW, MEDIUM, HIGH, RARE }

var worth_to_score = {ItemWorth.LOW: 1, ItemWorth.MEDIUM: 2, ItemWorth.HIGH: 5, ItemWorth.RARE: 10}

var worth = ItemWorth.LOW


# Called when the node enters the scene tree for the first time.
func _ready():
	# randomly choose an item worth (weighted)
	var rand = randf()
	if rand < 0.5:
		worth = ItemWorth.LOW
	elif rand < 0.75:
		worth = ItemWorth.MEDIUM
	elif rand < 0.9:
		worth = ItemWorth.HIGH
	else:
		worth = ItemWorth.RARE

	match worth:
		ItemWorth.LOW:
			$QualityLabel.text = "Low"
		ItemWorth.MEDIUM:
			$QualityLabel.text = "Medium"
		ItemWorth.HIGH:
			$QualityLabel.text = "High"
		ItemWorth.RARE:
			$QualityLabel.text = "Rare"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	hide()
	collected.emit(self)
	queue_free()
	$CollisionShape2D.set_deferred("disabled", true)
