extends CharacterBody2D

@export var speed: float = 40.0

@onready var sprite = $AnimatedSprite2D 
@onready var building_layer = $"../secondary_building" 

enum MovementState { MOVING_UP, MOVING_DOWN, MOVING_RIGHT, MOVING_LEFT }
var current_state = MovementState.MOVING_DOWN

const ANIMATIONS = {
	"movement": {
		MovementState.MOVING_UP: "move_up",
		MovementState.MOVING_DOWN: "move_down",
		MovementState.MOVING_LEFT: "move_left",
		MovementState.MOVING_RIGHT: "move_right",
	},
}

var debug_rect = Rect2()

func _process(_delta):
	queue_redraw() # Forces the red box to update every frame

func _draw():

	var top_left = Vector2(-20, -55) # Same as your offset above
	var size = Vector2(40, 50)       # Width (40) and Height (50)
	var rect = Rect2(top_left, size)
	
	draw_rect(rect, Color(1, 0, 0, 0.5), false, 2.0)

func _physics_process(_delta: float) -> void:
	# 1. Handle Movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	
	
	var top_left_offset = Vector2(-140, -65) 
	var bottom_right_offset = Vector2(160, -15)


	var local_top_left = building_layer.to_local(global_position + top_left_offset)
	var local_bottom_right = building_layer.to_local(global_position + bottom_right_offset)

	# 3. Get Map Coordinates
	var top_left_map = building_layer.local_to_map(local_top_left)
	var bottom_right_map = building_layer.local_to_map(local_bottom_right)
	
	var under_roof = false
	
	for x in range(top_left_map.x, bottom_right_map.x + 1):
		for y in range(top_left_map.y, bottom_right_map.y + 1):
			var tile_data = building_layer.get_cell_tile_data(Vector2i(x, y))

			if tile_data and tile_data.get_custom_data("is_hidden_zone") == true:
				# PRINT THE GHOST TILE LOCATION
				print("Ghost Roof Found at: ", Vector2i(x,y)) 
				under_roof = true
				break 
		if under_roof: break

	if under_roof:
		building_layer.target_opacity = 0.3
	else:
		building_layer.target_opacity = 1.0

func update_state(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		current_state = MovementState.MOVING_LEFT if direction.x < 0 else MovementState.MOVING_RIGHT
	else:
		current_state = MovementState.MOVING_UP if direction.y < 0 else MovementState.MOVING_DOWN

func play_animation() -> void:
	if sprite == null: return
	var anim_name = ANIMATIONS["movement"].get(current_state)
	if sprite.animation != anim_name:
		sprite.play(anim_name)
	
	if velocity == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0 
	else:
		if not sprite.is_playing():
			sprite.play()
