extends Node
# Stores the states of the game
# NOT a StateManager, surely I can't be bothered to do that clueless

# Switches shared across saves
static var score = 0
static var fragments = 0

# Tutorial related
static var cleared_tutorial = false
static var tut_item_displayed = false

# Evil
static var visited_evil = false

# Neuro
static var visited_neuro = false

# The end
static var visited_end = false
