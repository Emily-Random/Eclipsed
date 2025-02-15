extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var anim_player = $AnimatedSprite2D # 引用 Sprite 节点
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if direction > 0:
			anim_player.flip_h = false
		elif direction < 0:
			anim_player.flip_h = true
		if is_on_floor:
			anim_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim_player.play("idle")
		
	move_and_slide()
