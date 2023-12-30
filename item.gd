extends Area2D
class_name Item

signal collected

enum ItemWorth { NONE, LOW, MEDIUM, HIGH, RARE }

var worth_to_score = {
	ItemWorth.NONE: 0, ItemWorth.LOW: 1, ItemWorth.MEDIUM: 2, ItemWorth.HIGH: 5, ItemWorth.RARE: 10
}

@export var override_worth: ItemWorth = ItemWorth.NONE
var worth = ItemWorth.LOW

var in_contact = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if override_worth and override_worth != ItemWorth.NONE:
		worth = override_worth

	# randomly choose an item worth if not overwritten (weighted)
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
func _process(_delta):
	pass


func collect():
	hide()
	collected.emit(self)
	queue_free()
	$CollisionShape2D.set_deferred("disabled", true)
