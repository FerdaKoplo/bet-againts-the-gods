extends CharacterBody2D

@export var speed: float = 200.0
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
	if sprite == null:
		return

	var anim_name = ANIMATIONS["movement"].get(current_state)
	
	if sprite.animation != anim_name:
		sprite.play(anim_name)
	
	if velocity == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0
	else:
		if not sprite.is_playing():
			sprite.play()
var inventory := {}

func add_item(item_name: String, amount: int = 1):
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount

	print_inventory()

func print_inventory():
	print("=== INVENTORY PLAYER ===")
	for item in inventory.keys():
		print(item, "x", inventory[item])
		
var max_hp := 100
var hp := 70

func heal(amount: int):
	hp = min(hp + amount, max_hp)
	var loot_message = get_tree().get_first_node_in_group("loot_message")
	if loot_message:
		loot_message.show_message("Menggunakan Health Potion\nHP: %d / %d"
			% [hp, max_hp])
func use_item(item_name: String):
	if not inventory.has(item_name):
		return

	match item_name:
		"Health Potion":
			heal(20)
			inventory[item_name] -= 1

	if inventory[item_name] <= 0:
		inventory.erase(item_name)
