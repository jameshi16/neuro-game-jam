class_name LevelGenerator

static var turning_steps
static var turn_early_probability

var DIRECTIONS = [
	Vector2(0, 1),
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(-1, 0)
]

var level = []
var current_position
var current_direction = DIRECTIONS[randi() % DIRECTIONS.size()]
var bounding_box
var total_steps = 0
var steps = 0
var max_steps = 0
var visited = {}

# we will do an iterative DFS with a stack storing stack frames.
# otherwise we reach the recursion limit very quickly
var stack_frames = []

func _init(starting_position: Vector2, bounding: Rect2, num_steps: int):
	current_position = starting_position
	level.append(starting_position)
	bounding_box = bounding
	max_steps = num_steps

func dfs():
	# The directions array should already be randomized, called from the previous
	# iteration of DFS
	while !stack_frames.is_empty():
		var frame = stack_frames.pop_back()
		var position = frame['position']
		var directions = frame['directions']

		var is_bounded = bounding_box.has_point(position)
		if is_bounded and total_steps < max_steps:
			steps += 1
			total_steps += 1
			level.append(position)
			visited[position] = true
		else:
			continue

		for direction in directions:
			var next_position = position + direction
			var next_directions

			if steps == turning_steps or randf() > turn_early_probability:
				steps = 0
				next_directions = DIRECTIONS.duplicate()
				next_directions.shuffle()
			else:
				# favour the existing direction
				next_directions = directions.slice(1)
				next_directions.shuffle()
				next_directions.push_front(directions[0])

			if !visited.has(next_position):
				stack_frames.push_back({'position': next_position, 'directions': next_directions})


func generate_level() -> Array:
	stack_frames.append({
		'position': current_position,
		'directions': DIRECTIONS.duplicate()
	})
	dfs()
	return level
