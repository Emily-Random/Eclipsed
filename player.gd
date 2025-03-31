extends CharacterBody2D

var enemy: Node2D
const SPEED = 60.0
const JUMP_VELOCITY = -200.0
var health = 10
var in_shadow = false
var player_state = "Idle"
var player_death_anim = false
@onready var anim_player = $AnimatedSprite2D # Reference to the AnimatedSprite2D node

func _ready():
	enemy = get_tree().get_first_node_in_group("enemy") # get enemy
	
func _physics_process(delta: float) -> void:	
	anim_player.play(player_state)
	in_shadow = is_in_shadow() 
	if health <= 0:
		if player_death_anim:
			if anim_player.animation == "Death" and anim_player.frame == anim_player.sprite_frames.get_frame_count("Death") - 1:
				anim_player.visible = false  # Only hide when animation ends
		else:
			velocity.x = 0
			player_state = "Death"
			player_death_anim = true
		return
	# vertical movement
	if not is_on_floor():
		velocity += get_gravity() * delta  # Add gravity when not on the floor
	else:
		velocity.y = 0  # Reset vertical velocity when on the floor
	
	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		player_state = "Jump"
		velocity.y = JUMP_VELOCITY
				
	# horizontal movement
	var direction := Input.get_axis("Left", "Right") # get horizontal output

	if direction != 0: # calculate velocity & play animations
		velocity.x = direction * SPEED
		anim_player.flip_h = direction < 0
		if is_on_floor():
			player_state = "Walk"
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)  # Smooth deceleration
		if is_on_floor():
			if not(player_state == "Hurt" or player_state == "Attack"):
				player_state = "Idle"
	
	# attack
	if enemy and Input.is_action_just_pressed("Attack"):
		attack_enemy()

	# Move with slide
	move_and_slide()
	
	#for i in range(get_slide_collision_count()):
		#var collision = get_slide_collision(i)
		#print("Colliding with: ", collision.get_collider())

# animations for attacking enemy
func attack_enemy():
	player_state = "Attack"
	var anim_enemy = enemy.get_node("AnimatedSprite2D")
	if enemy.colliding_with_player:
		print("enemy collision")
		enemy.player_attacked = true
		enemy.enemy_state = "Hurt"
		enemy.player_attack_freeze()
	await anim_player.animation_finished
	enemy.player_attacked = false
	
func is_in_shadow():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("shadow_caster"):
			return true
	return false
