extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -567.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Sprite directoin
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
		
	# animation
		
	# move
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
