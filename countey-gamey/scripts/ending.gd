extends Node

const LINES := [
	{
		"speaker": 0,
		"emotion": "defeated",
		"text": "aww darn it, he got me im so cooked",
	},
	{
		"speaker": 1,
		"emotion": "triumphant",
		"text": "hahaha sending me",
	},
	{
		"speaker": 1,
		"emotion": "thinking",
		"text": "also im a duck my brains the size of a walnut why did i get what he was doing and everybody in fiction keeps ducking this up. lock in lads",
	},
	{
		"speaker": 1,
		"emotion": "neutral",
		"text": "quack",
	},
]

@onready var cutscene: Cutscene = $Cutscene
@onready var main_menu_button: Button = $EndCard/Background/BackToMainMenu

var _can_leave := false
var _leaving := false


func _ready() -> void:
	cutscene.play(LINES, GameFlow.CAST)
	await cutscene.finished
	_can_leave = true
	main_menu_button.grab_focus()


func _input(event: InputEvent) -> void:
	if _can_leave and event.is_pressed() and not event.is_echo():
		get_viewport().set_input_as_handled()
		_on_back_to_main_menu_pressed()


func _on_back_to_main_menu_pressed() -> void:
	if not _can_leave or _leaving:
		return
	_leaving = true
	GameFlow.go_to(GameFlow.State.MAIN_MENU)
