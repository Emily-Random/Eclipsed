extends CharacterBody2D

var player: Node2D  # Reference to player
const SPEED = 60.0
const JUMP_VELOCITY = -200.0
var frozen = false
var enemy_state = "Idle"
var last_direction = 1
var time = 0
var player_attacked = false

@onready var anim_enemy = $AnimatedSprite2D

func _ready():
	add_to_group("enemy")
	# Find player node (Assumes it's named "Player" in the scene)
	player = get_tree().get_first_node_in_group("player")
	$attack_timer.timeout.connect(_on_attack_timer_timeout)
	$player_attack_timer.timeout.connect(_on_player_attack_timer_timeout)
	
 # Reference to the AnimatedSprite2D node
	
func _physics_process(delta: float) -> void:
	anim_enemy.play(enemy_state)
	
	if not is_on_floor():
		velocity += get_gravity() * delta  # Add gravity when not on the floor
	else:
		velocity.y = 0
	
	if colliding_with_obstacle() and is_on_floor():
		velocity.y = JUMP_VELOCITY
		enemy_state = "Jump"
		
	if player and not frozen:
		var anim_player = player.get_node("AnimatedSprite2D")
		if anim_player:
			var direction = sign(anim_player.global_position.x - anim_enemy.global_position.x)
			
			if not is_on_floor():
				direction = last_direction
			else:
				last_direction = direction
			
			velocity.x = direction * SPEED
			anim_enemy.flip_h = direction < 0
		
		if is_on_floor():
			if not player.in_shadow:
				enemy_state = "Walk"
			else:
				print("Enemy stops chasing. Player is in shadow.")
				enemy_state = "Idle" 
				velocity.x = 0
				
				await get_tree().create_timer(1.0).timeout
				
				enemy_state = "Walk"
				var direction = -sign(player.global_position.x - anim_enemy.global_position.x)
				velocity.x = direction * SPEED
				anim_enemy.flip_h = direction < 0
			
		if colliding_with_player():
			attack_player()
				
	move_and_slide()
	
func colliding_with_player() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			print("player collision")
			return true
	return false
	
func colliding_with_obstacle() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("obstacle"):
			return true
	return false
		
func attack_player():
	enemy_state = "Attack"
	if player:
		var anim_player = player.get_node("AnimatedSprite2D")
		player.player_state = "Hurt"
		player.health -= 2
	attack_freeze()

func attack_freeze():
	frozen = true
	if player_attacked:
		await $player_attack_timer.timeout
	$attack_timer.start()

func player_attack_freeze():
	print("player attack freeze")
	frozen = true
	$player_attack_timer.start()
	
func _on_attack_timer_timeout():
	print("attack freeze")
	frozen = false
	velocity.x = 0

func _on_player_attack_timer_timeout():
	if enemy_state != "Attack":
		frozen = false
		velocity.x = 0
	
	
