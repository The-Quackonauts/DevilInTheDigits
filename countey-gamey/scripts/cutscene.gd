class_name Cutscene
extends CanvasLayer

signal finished

@export_range(1.0, 100.0, 1.0) var characters_per_second := 42.0
@export_range(0.0, 1.0, 0.05) var inactive_brightness := 0.35
@export_range(0.0, 1.0, 0.05) var fade_seconds := 0.2
@export_range(0.0, 2.0, 0.05) var input_delay_seconds := 0.5

@onready var portraits: Array[TextureRect] = [$Screen/LeftPortrait, $Screen/RightPortrait]
@onready var heading_label: Label = $Screen/Heading
@onready var speaker_label: Label = $Screen/TextBox/Speaker
@onready var dialogue_label: RichTextLabel = $Screen/TextBox/Dialogue
@onready var continue_label: Label = $Screen/TextBox/Continue

var _cast: Array
var _lines: Array
var _line_index := -1
var _shown_characters := 0.0
var _typing := false
var _playing := false
var _was_paused := false
var _accept_input_after := 0
var _fade: Tween


func play(lines: Array, cast: Array) -> void:
	assert(not lines.is_empty(), "A cutscene needs at least one line.")
	assert(cast.size() == 2, "A cutscene needs exactly two characters.")
	for character in cast:
		assert(character.has("name") and character.has("portraits"))

	_lines = lines
	_cast = cast
	_line_index = -1
	_playing = true
	_accept_input_after = Time.get_ticks_msec() + int(input_delay_seconds * 1000.0)
	_was_paused = get_tree().paused
	get_tree().paused = true
	show()
	heading_label.hide()

	for side in 2:
		portraits[side].show()
		portraits[side].texture = _portrait(side, "neutral")
		portraits[side].modulate = Color.WHITE if side == 0 else _inactive_color()

	_next_line()


func _process(delta: float) -> void:
	if not _typing:
		return

	_shown_characters += characters_per_second * delta
	dialogue_label.visible_characters = floori(_shown_characters)
	if dialogue_label.visible_characters >= dialogue_label.get_total_character_count():
		_finish_typing()


func _input(event: InputEvent) -> void:
	if not _playing or Time.get_ticks_msec() < _accept_input_after:
		return

	if event.is_pressed() and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _typing:
			_finish_typing()
		else:
			_next_line()


func _next_line() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		_end()
		return

	var line: Dictionary = _lines[_line_index]
	var speaker: int = line["speaker"]
	assert(speaker == 0 or speaker == 1)
	assert(line.has("text"))

	if line.has("heading"):
		heading_label.text = line["heading"]
		heading_label.show()
	var solo: bool = line.get("solo", false)
	for side in 2:
		portraits[side].visible = not solo or side == speaker

	speaker_label.text = _cast[speaker]["name"]
	dialogue_label.text = line["text"]
	dialogue_label.visible_characters = 0
	continue_label.hide()
	_shown_characters = 0.0
	_typing = true

	var emotion: String = line.get("emotion", "neutral")
	portraits[speaker].texture = _portrait(speaker, emotion)
	_fade_speaker(speaker)


func _finish_typing() -> void:
	_typing = false
	dialogue_label.visible_characters = -1
	continue_label.show()


func _fade_speaker(active: int) -> void:
	if _fade:
		_fade.kill()
	_fade = create_tween().set_parallel()
	for side in 2:
		var color := Color.WHITE if side == active else _inactive_color()
		_fade.tween_property(portraits[side], "modulate", color, fade_seconds)


func _portrait(side: int, emotion: String) -> Texture2D:
	var options: Dictionary = _cast[side]["portraits"]
	assert(options.has(emotion) or options.has("neutral"),
		"%s needs a '%s' or 'neutral' portrait." % [_cast[side]["name"], emotion])
	return options.get(emotion, options.get("neutral")) as Texture2D


func _inactive_color() -> Color:
	return Color(inactive_brightness, inactive_brightness, inactive_brightness, 1.0)


func _end() -> void:
	_playing = false
	hide()
	get_tree().paused = _was_paused
	finished.emit()


func _exit_tree() -> void:
	if _playing:
		get_tree().paused = _was_paused
