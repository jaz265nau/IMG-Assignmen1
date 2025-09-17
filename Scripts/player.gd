extends CharacterBody2D

var key_collected = false
var coins_collected = 0

const SPEED = 400.0
const JUMP_VELOCITY = -575.0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		$AnimatedSprite2D.play("Jump")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		if is_on_floor():
			$AnimatedSprite2D.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if is_on_floor():
			$AnimatedSprite2D.play("Idle")
		
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
	if direction == 1:
		$AnimatedSprite2D.flip_h = false

	move_and_slide()
