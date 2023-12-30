extends SpecialLevelBase
class_name SLB_Tutorial

# Implementing a simple state manager just for this scene to prove that I can do it
# and I'm just choosing not to

static func show_dialogue(title: String):
	# abstraction so that I can change the dialogue balloon later
	# (surely that will happen)
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/tutorial.dialogue"), title)

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

class Stage3State extends BaseState:
	func _process(_delta: float) -> void:
		return

	func advance_maybe() -> BaseState:
		return null

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
		if shift_pressed and !Input.is_action_pressed("sprint") and !part1:
			state_parent.get_node("TutorialItem1").show()
			SLB_Tutorial.show_dialogue("tutorial_3")
			part1 = true

		if State.tut_item_displayed:
			state_parent.get_node("TutorialItem1").hide()
			# SLB_Tutorial.show_dialogue("tutorial_3_5")
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
		if w_pressed and a_pressed and s_pressed and d_pressed:
			SLB_Tutorial.show_dialogue("tutorial_2")
			return SLB_Tutorial.Stage2State.new(state_parent)
		return self


var state = SLB_Tutorial.Stage1State.new(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TutorialItem1.hide()
	$TutorialItem2.hide()
	$TutorialItem3.hide()
	$TutorialItem4.hide()
	DialogueManager.got_dialogue.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func level_began() -> void:
	SLB_Tutorial.show_dialogue("tutorial_1")

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state:
		state._process(delta)
		state = state.advance_maybe()


func _on_item_collected(item) -> void:
	item_picked.emit(item)
