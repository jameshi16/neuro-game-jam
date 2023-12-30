extends CharacterBody2D
class_name Enemy

@export var speed = 100
@export var health = 100

var target: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if target:
		var direction = $NavigationAgent2D.get_next_path_position()
		var collision = move_and_collide((direction - position).normalized() * speed * delta)
		if collision and collision.get_collider() is Player:
			var player: Player = collision.get_collider()
			player.enemy_damages_player(self)


func set_navigation_map(navigation_map: RID):
	# Godot literally doesn't say it defaults to the background layer by default, I am very madge
	$NavigationAgent2D.set_navigation_map(navigation_map)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_navigation_timer_timeout() -> void:
	if target:
		$NavigationAgent2D.target_position = target.position

func receive_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		queue_free()
