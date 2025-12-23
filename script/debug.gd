extends CharacterBody2D

@export var speed: float = 70.0

# Remove the '#' so the script can actually see the sprite node
@onready var sprite = $AnimatedSprite2D 

enum MovementState {
	MOVING_UP,
	MOVING_DOWN,
	MOVING_RIGHT,
	MOVING_LEFT,
}

var current_state = MovementState.MOVING_DOWN

const ANIMATIONS = {
	"movement": {
		MovementState.MOVING_UP: "move_up",
		MovementState.MOVING_DOWN: "move_down",
		MovementState.MOVING_LEFT: "move_left",
		MovementState.MOVING_RIGHT: "move_right",
	},
}

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Force 4-way movement logic
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			direction.y = 0
		else:
			direction.x = 0
		direction = direction.normalized()
		update_state(direction)

	velocity = direction * speed
	
	play_animation()
	move_and_slide()

func update_state(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		current_state = MovementState.MOVING_LEFT if direction.x < 0 else MovementState.MOVING_RIGHT
	else:
		current_state = MovementState.MOVING_UP if direction.y < 0 else MovementState.MOVING_DOWN

func play_animation() -> void:
	# If for some reason the sprite is still missing, this avoids a crash
	if sprite == null:
		return

	var anim_name = ANIMATIONS["movement"].get(current_state)
	
	# 1. Update the animation name if it changed
	if sprite.animation != anim_name:
		sprite.play(anim_name)
	
	# 2. Check if we are standing still
	if velocity == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0 # Sets the sprite to the first frame
	else:
		# Resume playing if we are moving
		if not sprite.is_playing():
			sprite.play()
