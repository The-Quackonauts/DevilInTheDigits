extends Node2D


@export_range(0.5, 60.0, 0.5)
var seconds_per_digit: float = 6.7

@onready var _8: Node2D = $"8"
@onready var digit_timer: Timer = $DigitTimer
@onready var countdown_label: Label = $CountdownLabel


func _ready() -> void:
	digit_timer.wait_time = seconds_per_digit
	digit_timer.one_shot = false
	digit_timer.timeout.connect(_on_digit_timer_timeout)
	digit_timer.start()


func _process(_delta: float) -> void:
	countdown_label.text = "Next number in: %.1f" % digit_timer.time_left


func _on_digit_timer_timeout() -> void:
	_8.current_digit -= 1
