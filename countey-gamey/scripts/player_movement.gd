extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -567.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var floating := false
var can_float := false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if floating:
			velocity += get_gravity() * delta * 0.2
	else:
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# floating
	if Input.is_action_just_released("jump") and not is_on_floor():
		can_float = true
	if Input.is_action_pressed("jump") and not is_on_floor() and can_float and velocity.y > 0:
		floating = true
	else:
		floating = false

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Sprite directoin
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
		
	# animation
	if is_on_floor():	
		if direction == 0:
			sprite.play("idle")
		else:
			sprite.play("run")
	else:
		if floating == true:
			sprite.play("floating")	
		else:
			sprite.play("run")
	# move
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
