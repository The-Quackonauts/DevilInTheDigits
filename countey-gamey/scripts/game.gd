extends Node2D

@export_range(0.5, 60.0, 0.5)
var seconds_per_digit: float = 6.7

@onready var _8: Node2D = $"8"
@onready var coins: Node2D = $"8/Coins"
@onready var digit_timer: Timer = $DigitTimer
@onready var countdown_label: Label = $CountdownLabel
@onready var coin_counter: Label = $HUD/CoinCounter

var coins_collected := 0
var total_coins := 0


func _ready() -> void:
	total_coins = coins.get_child_count()
	for coin: Area2D in coins.get_children():
		coin.body_entered.connect(_collect_coin.bind(coin))

	digit_timer.wait_time = seconds_per_digit
	digit_timer.one_shot = false
	digit_timer.timeout.connect(_on_digit_timer_timeout)
	digit_timer.start()


func _process(_delta: float) -> void:
	countdown_label.text = "Next number in: %.1f" % digit_timer.time_left


func _on_digit_timer_timeout() -> void:
	_8.current_digit -= 1


func _collect_coin(_body: Node2D, coin: Area2D) -> void:
	coin.set_deferred("monitoring", false)
	coin.queue_free()
	coins_collected += 1
	coin_counter.text = "Coins: %d" % coins_collected
	if coins_collected == total_coins:
		GameFlow.go_to(GameFlow.State.ENDING)
