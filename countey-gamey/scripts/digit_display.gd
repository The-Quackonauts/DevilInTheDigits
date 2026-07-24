extends Node2D

const DIGIT_MASKS := [
	0b0111111, # 0
	0b0000110, # 1
	0b1011011, # 2
	0b1001111, # 3
	0b1100110, # 4
	0b1101101, # 5
	0b1111101, # 6
	0b0000111, # 7
	0b1111111, # 8
	0b1101111, # 9
]

@export_range(0.1, 20.0, 0.1) var rotation_follow_speed := 6.0

@onready var segments := [$A, $B, $C, $D, $E, $F, $G]

var current_digit := 9:
	set(value):
		current_digit = wrapi(value, 0, 10)
		if is_node_ready():
			_update_segments()

var dragging := false


func _ready() -> void:
	_update_segments()


func _physics_process(delta: float) -> void:
	if dragging:
		var mouse_angle := (get_global_mouse_position() - global_position).angle()
		_smooth_rotation_toward(mouse_angle, delta)
		return

	var turn_input := Input.get_axis("rotate_left", "rotate_right")
	rotation = wrapf(rotation + turn_input * rotation_follow_speed * delta, -PI, PI)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed


func _smooth_rotation_toward(target_angle: float, delta: float) -> void:
	var weight := 1.0 - exp(-rotation_follow_speed * delta)
	rotation = lerp_angle(rotation, target_angle, weight)


func _update_segments() -> void:
	var mask: int = DIGIT_MASKS[current_digit]
	for index in segments.size():
		var segment := segments[index] as AnimatableBody2D
		var enabled := (mask & (1 << index)) != 0
		segment.visible = enabled
		segment.get_node("CollisionShape2D").disabled = not enabled
