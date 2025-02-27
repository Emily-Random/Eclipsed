extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var anim_player = $AnimatedSprite2D # Reference to the AnimatedSprite2D node

func _physics_process(delta: float) -> void:
	# Handle gravity and vertical movement
	if not is_on_floor():
		velocity += get_gravity() * delta  # Add gravity when not on the floor
	else:
		velocity.y = 0  # Reset vertical velocity when on the floor

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get horizontal input
	var direction := Input.get_axis("Left", "Right")

	if direction != 0:
		velocity.x = direction * SPEED
		if direction > 0:
			anim_player.flip_h = false
		elif direction < 0:
			anim_player.flip_h = true
		if is_on_floor():
			anim_player.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)  # Smooth deceleration
		anim_player.play("Idle")
	# Move with slide, handling collisions automatically

	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		print("Colliding with: ", collision.get_collider())
