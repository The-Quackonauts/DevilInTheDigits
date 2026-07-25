extends Control


func _ready() -> void:
	$Background/Center/Menu/Play.grab_focus()


func _on_play_pressed() -> void:
	GameFlow.go_to(GameFlow.State.INTRO)
