extends Node

enum State { INTRO, GAMEPLAY, ENDING }

const SCENES := [
	"res://scenes/intro.tscn",
	"res://scenes/game.tscn",
	"res://scenes/ending.tscn",
]
const PLACEHOLDER_PORTRAIT := preload("res://icon.svg")
const CAST := [
	{
		"name": "Devil",
		"portraits": {
			"neutral": PLACEHOLDER_PORTRAIT,
			"smug": PLACEHOLDER_PORTRAIT,
			"excited": PLACEHOLDER_PORTRAIT,
			"panicked": PLACEHOLDER_PORTRAIT,
			"defeated": PLACEHOLDER_PORTRAIT,
		},
	},
	{
		"name": "Duck",
		"portraits": {
			"neutral": PLACEHOLDER_PORTRAIT,
			"sad": PLACEHOLDER_PORTRAIT,
			"thinking": PLACEHOLDER_PORTRAIT,
			"whispering": PLACEHOLDER_PORTRAIT,
			"triumphant": PLACEHOLDER_PORTRAIT,
		},
	},
]

var state := State.INTRO


func go_to(next_state: State) -> void:
	state = next_state
	var error := get_tree().change_scene_to_file(SCENES[state])
	assert(error == OK, "Could not load %s" % SCENES[state])
