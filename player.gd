extends CharacterBody2D

const SPEED = 300.0
@onready var player = $AnimatedSprite2D # Reference to AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	# Get input for movement in all directions
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Normalize direction to maintain consistent speed diagonally
	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * SPEED
		player.play("walk")
	else:
		velocity = Vector2.ZERO
		player.play("idle")

	# Flip sprite based on movement direction (optional)
	if direction.x > 0:
		player.flip_h = false
	elif direction.x < 0:
		player.flip_h = true

	move_and_slide()
