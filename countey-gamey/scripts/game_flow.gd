extends Node

enum State { MAIN_MENU, INTRO, GAMEPLAY, TIME_VORTEX, ENDING }

const SCENES := [
	"res://scenes/main_menu.tscn",
	"res://scenes/intro.tscn",
	"res://scenes/game.tscn",
	"res://scenes/time_vortex.tscn",
	"res://scenes/ending.tscn",
]
const PLACEHOLDER_PORTRAIT := preload("res://icon.svg")
const CAST := [
	{
		"name": "Devil",
		"portraits": {
			"neutral": preload("uid://cu0faa8xeuacq"),
			"smug": preload("uid://cwybbnj8s6w87"),
			"excited": preload("uid://brnd34as88dof"),
			"panicked": preload("uid://qtc8rs4g8rwv"),
			"defeated": preload("uid://bs101l7otrdwx"),
		},
	},
	{
		"name": "Duck",
		"portraits": {
			"neutral": preload("uid://7hu17c675q7s"),
			"sad": preload("uid://1yjcakmpjj3y"),
			"thinking": preload("uid://7m7lh3biuyh7"),
			"whispering": preload("uid://batbynouyyf84"),
			"triumphant": preload("uid://bdb8o6u55gjua"),
		},
	},
]

var state := State.MAIN_MENU


func go_to(next_state: State) -> void:
	state = next_state
	var error := get_tree().change_scene_to_file(SCENES[state])
	assert(error == OK, "Could not load %s" % SCENES[state])
