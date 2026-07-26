extends Node

const LINES := [
	{
		"speaker": 0,
		"emotion": "defeated",
		"heading": "THE STONE AGE — 2,500,000 BC",
		"solo": true,
		"text": "aww darn it. he sent me to the stone age instead of him. im so cooked",
	},
	{
		"speaker": 0,
		"emotion": "smug",
		"solo": true,
		"text": "fine. new plan: become king of the cavemen",
	},
	{
		"speaker": 1,
		"emotion": "sad",
		"heading": "THE CEMETERY — 2026",
		"solo": true,
		"text": "the devil is gone. but youre also still gone",
	},
	{
		"speaker": 1,
		"emotion": "sad",
		"solo": true,
		"text": "i miss you",
	},
	{
		"speaker": 1,
		"emotion": "sad",
		"solo": true,
		"text": "quack",
	},
]

@onready var cutscene: Cutscene = $Cutscene
@onready var main_menu_button: Button = $EndCard/Background/BackToMainMenu
@onready var completion_time_label: Label = \
	$EndCard/Background/Center/Results/CompletionTime

var _can_leave := false
var _leaving := false


func _ready() -> void:
	completion_time_label.text = GameFlow.format_gameplay_time(
		GameFlow.get_gameplay_time()
	)
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
