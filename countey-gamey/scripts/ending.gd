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


func _ready() -> void:
	cutscene.play(LINES, GameFlow.CAST)
	await cutscene.finished
	main_menu_button.grab_focus()


func _on_back_to_main_menu_pressed() -> void:
	GameFlow.go_to(GameFlow.State.MAIN_MENU)
