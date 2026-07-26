extends Node

enum State { MAIN_MENU, INTRO, GAMEPLAY, ENDING }

const SCENES := [
	"res://scenes/main_menu.tscn",
	"res://scenes/intro.tscn",
	"res://scenes/game.tscn",
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
			"weeping": preload("res://assets/Duck/Duck_Weeping.png")
		},
	},
]

var state := State.MAIN_MENU
var _transition_pending := false
var _gameplay_elapsed_seconds := 0.0
var _gameplay_started_at_msec := 0
var _gameplay_timer_running := false


func reset_gameplay_timer() -> void:
	_gameplay_elapsed_seconds = 0.0
	_gameplay_started_at_msec = 0
	_gameplay_timer_running = false


func start_gameplay_timer() -> void:
	if _gameplay_timer_running:
		return
	_gameplay_started_at_msec = Time.get_ticks_msec()
	_gameplay_timer_running = true


func get_gameplay_time() -> float:
	if _gameplay_timer_running:
		return _gameplay_elapsed_seconds + (
			Time.get_ticks_msec() - _gameplay_started_at_msec
		) / 1000.0
	return _gameplay_elapsed_seconds


func finish_gameplay_timer() -> void:
	_gameplay_elapsed_seconds = get_gameplay_time()
	_gameplay_timer_running = false


func format_gameplay_time(seconds: float) -> String:
	var tenths := floori(seconds * 10.0)
	var minutes := int(tenths / 600)
	var remaining_seconds := int(tenths / 10) % 60
	return "%02d:%02d.%d" % [minutes, remaining_seconds, tenths % 10]


func go_to(next_state: State) -> void:
	if _transition_pending:
		return
	_transition_pending = true
	call_deferred("_change_scene", next_state)


func _change_scene(next_state: State) -> void:
	state = next_state
	var error := get_tree().change_scene_to_file(SCENES[state])
	_transition_pending = false
	assert(error == OK, "Could not load %s" % SCENES[state])
