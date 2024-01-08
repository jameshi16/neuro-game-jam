extends SpecialLevelBase

var cutscene_done = false
var can_complete_level = false
var cutscene
const Balloon = preload("res://dialogue/balloon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_conversation_ended)
	player.finished_digging.connect(_on_player_dug)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_dug() -> void:
	if can_complete_level:
		State.visited_end = true
		# credits here
		cutscene = preload("res://special_levels/cutscene_credits.tscn").instantiate()
		cutscene.play("sequence")

		add_child(cutscene)
		hide()
		cutscene.get_node("Camera2D").make_current()
		cutscene.animation_finished.connect(_on_credits_ended)

func _on_grave_area_body_entered(body:Node2D) -> void:
	if body is Player:
		$GraveArea/Label.show()
		can_complete_level = true

func _on_grave_area_body_exited(body:Node2D) -> void:
	if body is Player:
		$GraveArea/Label.hide()
		can_complete_level = false

func _on_hiyori_area_body_entered(body:Node2D) -> void:
	if body is Player:
		hud.hide()
		player.keys_disabled = true
		player.get_node("AnimatedSprite2D").play("idle_side")
		player.get_node("AnimatedSprite2D").flip_h = false
		var balloon = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://dialogue/special_levels.dialogue"), "hiyori_1")
		$HiyoriArea/CollisionShape2D.set_deferred('disabled', true)

func _on_conversation_ended(_not_used) -> void:
	if !cutscene_done:
		cutscene = preload("res://special_levels/cutscene_vedal.tscn").instantiate()
		cutscene.play("sequence")
		# :clueless:, too lazy to swap scenes, so we'll just spawn it somewhere away from the level
		add_child(cutscene)
		hide()
		cutscene.get_node("Camera2D").make_current()
		cutscene.animation_finished.connect(_on_cutscene_ended)
		return

	$NPCHiyori.hide()
	$NPCHiyori.queue_free()
	player.keys_disabled = false
	player.get_node("AnimatedSprite2D").sprite_frames = preload("res://arg_swapin.tres")

func _on_cutscene_ended(_not_used) -> void:
	cutscene_done = true
	show()
	player.get_node("Camera2D").make_current()
	cutscene.queue_free()
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://dialogue/special_levels.dialogue"), "hiyori_2")

func _on_credits_ended(_not_used) -> void:
	level_completed.emit()
