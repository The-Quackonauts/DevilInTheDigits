extends Control

var _starting := false


func _ready() -> void:
	$Background/Center/Menu/Play.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		get_viewport().set_input_as_handled()
		_on_play_pressed()


func _on_play_pressed() -> void:
	if _starting:
		return
	_starting = true
	GameFlow.go_to(GameFlow.State.INTRO)
