extends CharacterBody2D
class_name Enemy

@export var speed = 100
@export var health = 100

var target: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if target:
		var collision = Steering.follow_linear(self, target.position, speed, delta)
		if collision and collision.get_collider() is Player:
			var player: Player = collision.get_collider()
			player.enemy_damages_player(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
