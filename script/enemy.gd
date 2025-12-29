extends CharacterBody2D

# ------------------ CONFIG ------------------
@export var speed: float = 100.0
@export var stop_distance: float = 0.0

@export var vision_range: float = 220.0
@export var lose_aggro_range: float = 260.0
@export var vision_angle: float = 90.0 # degrees

# ------------------ NODES -------------------
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ------------------ STATE -------------------
var aggro: bool = false
var facing_dir: Vector2 = Vector2.DOWN
var last_facing: String = "down"

# ------------------ MAIN LOOP ---------------
func _physics_process(delta: float) -> void:
	if player == null:
		return

	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()

	# -------- AGGRO / LOS LOGIC --------
	if aggro:
		if distance > lose_aggro_range:
			aggro = false
	else:
		if _can_see_player(to_player, distance):
			aggro = true

	# -------- MOVEMENT & ANIMATION --------
	if aggro and distance > stop_distance:
		velocity = to_player.normalized() * speed
		facing_dir = velocity.normalized()
		_update_animation(velocity)
	else:
		velocity = Vector2.ZERO
		_play_idle()

	move_and_slide()

# ------------------ LOS CHECK ----------------
func _can_see_player(to_player: Vector2, distance: float) -> bool:
	# Distance
	if distance > vision_range:
		return false

	# Vision cone (front only)
	var dir_to_player := to_player.normalized()
	var dot := facing_dir.dot(dir_to_player)
	var angle := rad_to_deg(acos(clamp(dot, -1.0, 1.0)))

	if angle > vision_angle * 0.5:
		return false

	# Raycast (walls block vision)
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	query.exclude = [self]

	var result := space.intersect_ray(query)

	if result and result.collider != player:
		return false

	return true

# ------------------ ANIMATION ----------------
func _update_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			sprite.play("right")
			last_facing = "right"
		else:
			sprite.play("left")
			last_facing = "left"
	else:
		if direction.y > 0:
			sprite.play("down")
			last_facing = "down"
		else:
			sprite.play("up")
			last_facing = "up"

func _play_idle() -> void:
	if sprite.is_playing():
		sprite.stop()

	# Hold last facing direction
	sprite.animation = last_facing
	sprite.frame = 0
