extends Node2D

const PORTAL_SCENE := preload("res://scenes/portal.tscn")
const PORTAL_POSITION := Vector2(720, 112)
const PORTAL_FADE_SECONDS := 0.4
const PLAYER_DROP_DISTANCE := 70.0
const PLAYER_DROP_SECONDS := 0.45
const COIN_CHARGE_MAX := 66.0
const FINAL_CHARGE_SECONDS := 5.0

@export_range(0.5, 60.0, 0.5)
var seconds_per_digit: float = 6.7

@onready var _8: Node2D = $"8"
@onready var coins: Node2D = $"8/Coins"
@onready var digit_timer: Timer = $DigitTimer
@onready var countdown_label: Label = $CountdownLabel
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound
@onready var time_vortex = $TimeVortex
@onready var portal_noise: AudioStreamPlayer2D = $PortalNoise
@onready var player: CharacterBody2D = $Player

var coins_collected := 0
var total_coins := 0


func _ready() -> void:
	total_coins = coins.get_child_count()
	for coin: Area2D in coins.get_children():
		coin.body_entered.connect(_collect_coin.bind(coin))

	digit_timer.wait_time = seconds_per_digit
	digit_timer.one_shot = false
	digit_timer.timeout.connect(_on_digit_timer_timeout)
	countdown_label.text = "Get ready..."
	await _play_opening()
	digit_timer.start()


func _process(_delta: float) -> void:
	if not digit_timer.is_stopped():
		countdown_label.text = "Next number in: %.1f" % digit_timer.time_left


func _play_opening() -> void:
	var portal := PORTAL_SCENE.instantiate() as Area2D
	portal.position = player.position + Vector2.UP * 28.0
	add_child(portal)
	portal_noise.play()

	_8.process_mode = Node.PROCESS_MODE_DISABLED
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(PORTAL_FADE_SECONDS).timeout

	var drop := create_tween()
	drop.tween_property(
		player, "position:y", player.position.y + PLAYER_DROP_DISTANCE, PLAYER_DROP_SECONDS
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await drop.finished

	var fade := create_tween()
	fade.tween_property(portal, "modulate:a", 0.0, PORTAL_FADE_SECONDS)
	await fade.finished
	portal.queue_free()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	_8.process_mode = Node.PROCESS_MODE_INHERIT


func _on_digit_timer_timeout() -> void:
	_8.current_digit -= 1


func _collect_coin(_body: Node2D, coin: Area2D) -> void:
	coin.set_deferred("monitoring", false)
	coin.queue_free()
	pickup_sound.play()
	coins_collected += 1
	var charge_finished: Signal = time_vortex.charge_to(
		float(coins_collected) / total_coins * COIN_CHARGE_MAX
	)
	if coins_collected == total_coins:
		await charge_finished
		await time_vortex.charge_to(100.0, FINAL_CHARGE_SECONDS)
		var portal := PORTAL_SCENE.instantiate() as Area2D
		portal.position = PORTAL_POSITION
		portal.body_entered.connect(_enter_portal)
		portal.monitoring = false
		portal.modulate.a = 0.0
		add_child(portal)
		portal_noise.play()
		var fade := create_tween()
		fade.tween_property(portal, "modulate:a", 1.0, PORTAL_FADE_SECONDS)
		await fade.finished
		portal.monitoring = true


func _enter_portal(_body: Node2D) -> void:
	GameFlow.go_to(GameFlow.State.ENDING)
