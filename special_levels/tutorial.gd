extends SpecialLevelBase
class_name SLB_Tutorial

const Balloon = preload("res://dialogue/balloon.tscn")

# Implementing a simple state manager just for this scene to prove that I can do it
# and I'm just choosing not to
# The DialogueManager can actually also set the state directly, but it's fine :clueless:

func show_dialogue(title: String):
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://dialogue/tutorial.dialogue"), title)

class BaseState:
	var keys_enabled = false
	var dialog_up = false
	var state_parent: SLB_Tutorial

	func _init(caller: SLB_Tutorial):
		state_parent = caller

	func _process(_delta: float) -> void:
		return

	func advance_maybe() -> BaseState:
		return null

class Stage5State extends BaseState:
	var attacked = false
	static var items_to_check = ["TutorialItem2", "TutorialItem3", "TutorialItem4"]

	func _process(_delta: float) -> void:
		if !keys_enabled:
			return

		if Input.is_action_pressed("attack"):
			attacked = true

	func advance_maybe() -> BaseState:
		for item in items_to_check:
			if state_parent.get_node(item):
				return self

		state_parent.show_dialogue("tutorial_6")
		return SLB_Tutorial.BaseState.new(state_parent)

class Stage4State extends BaseState:
	var attacked = false

	func _process(_delta: float) -> void:
		if !keys_enabled:
			return

		if Input.is_action_pressed("attack"):
			attacked = true

	func advance_maybe() -> BaseState:
		if attacked:
			state_parent.show_dialogue("tutorial_5")
			state_parent.get_node("TutorialItem2").show()
			state_parent.get_node("TutorialItem3").show()
			state_parent.get_node("TutorialItem4").show()
			return SLB_Tutorial.Stage5State.new(state_parent)
		return self

class Stage3State extends BaseState:
	func _process(_delta: float) -> void:
		pass

	func advance_maybe() -> BaseState:
		if !state_parent.get_node("TutorialItem1"):
			state_parent.show_dialogue("tutorial_4")
			return SLB_Tutorial.Stage4State.new(state_parent)
		return self

class Stage2State extends BaseState:
	static var movement_actions = ["move_up", "move_left", "move_right", "move_down"]
	var shift_pressed = false
	var part1 = false # im lazy pls

	func _process(_delta: float) -> void:
		if !keys_enabled:
			return

		if Input.is_action_pressed("sprint"):
			for action in movement_actions:
				if Input.is_action_pressed(action):
					shift_pressed = true

	func advance_maybe() -> BaseState:
		var player: Player = state_parent.player
		assert(player is Player)
		var camera: Camera2D = player.get_node("Camera2D")

		if shift_pressed and !Input.is_action_pressed("sprint") and !part1:
			state_parent.get_node("TutorialItem1").show()
			state_parent.show_dialogue("tutorial_3")
			part1 = true

			if camera:
				camera.position = state_parent.get_node("TutorialItem1").position

		if State.tut_item_displayed:
			state_parent.get_node("TutorialItem1").hide()
			if camera:
				camera.position = Vector2(0, 0)

			return SLB_Tutorial.Stage3State.new(state_parent)
		return self

class Stage1State extends BaseState:
	var w_pressed = false
	var a_pressed = false
	var s_pressed = false
	var d_pressed = false

	func _process(_delta: float) -> void:
		# this should mirror the player's keys
		if !keys_enabled:
			return

		if Input.is_action_just_pressed("move_up"):
			w_pressed = true

		if Input.is_action_just_pressed("move_left"):
			a_pressed = true

		if Input.is_action_just_pressed("move_right"):
			d_pressed = true

		if Input.is_action_just_pressed("move_down"):
			s_pressed = true

	func advance_maybe() -> BaseState:
		# world's best code, could have used a bitmask omegalul
		if [w_pressed, a_pressed, s_pressed, d_pressed].count(true) == 3:
			state_parent.show_dialogue("tutorial_2")
			return SLB_Tutorial.Stage2State.new(state_parent)
		return self


var state = SLB_Tutorial.Stage1State.new(self)
var tutorial_item_1_picked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TutorialItem1.hide()
	$TutorialItem2.hide()
	$TutorialItem3.hide()
	$TutorialItem4.hide()

	DialogueManager.got_dialogue.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func level_began() -> void:
	self.show_dialogue("tutorial_1")

func _on_dialogue_started(_not_used):
	player.keys_disabled = true
	if state:
		state.keys_enabled = false
		state.dialog_up = true

func _on_dialogue_ended(_not_used):
	player.keys_disabled = false
	if state:
		state.keys_enabled = true
		state.dialog_up = false
	else:
		State.cleared_tutorial = true
		level_completed.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state:
		state._process(delta)
		state = state.advance_maybe()


func _on_item_collected(item) -> void:
	item_picked.emit(item)
