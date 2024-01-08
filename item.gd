extends Area2D
class_name Item

signal collected

enum ItemWorth { NONE, LOW, MEDIUM, HIGH, RARE }

var worth_to_score = {
	ItemWorth.NONE: 0, ItemWorth.LOW: 2, ItemWorth.MEDIUM: 4, ItemWorth.HIGH: 6, ItemWorth.RARE: 10
}

var worth_to_color = {
	ItemWorth.NONE: Color(0, 0, 0), ItemWorth.LOW: Color("fffd00", 1.0), ItemWorth.MEDIUM: Color("5bff00", 1.0), ItemWorth.HIGH: Color("0022ff", 1.0), ItemWorth.RARE: Color("ff00c4", 1.0)
}

@export var override_worth: ItemWorth = ItemWorth.NONE
var worth = ItemWorth.LOW

var in_contact = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# randomly choose one of the two sprites
	$AnimatedSprite2D.set_frame(randi() % 2)

	if override_worth and override_worth != ItemWorth.NONE:
		worth = override_worth
	else:
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

	$QualityIndicator.modulate = worth_to_color[worth]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func collect():
	hide()
	collected.emit(self)
	queue_free()
	$CollisionShape2D.set_deferred("disabled", true)
