extends Control

enum States {
	OPTIONS,
	TARGETS,
	BUSY,
}

@export var enemy: Resource = null

var state: States = States.OPTIONS
var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

@onready var _options: WindowDefault = $Options
@onready var _options_menu: Menu = $Options/Options
@onready var _enemies_menu: Menu = $Enemies

func _ready() -> void:
	_options_menu.button_focus(0)
	set_health($Enemies/BattleEnemy/ProgressBar, enemy.health, enemy.health)
	set_health($GUIMargin/Bottom/Players/MarginContainer/VBoxContainer/BattlePlayerBar/ProgressBar, State.current_health, State.max_health)
	_options_menu.connect_to_buttons(self)
	_enemies_menu.connect_to_buttons(self)
	#$Enemies/BattleEnemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state = States.OPTIONS
				_options_menu.button_focus()
	
func _on_options_button_focused(button: BaseButton) -> void:
	pass
	
func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			state = States.TARGETS
			_enemies_menu.button_focus()
			

func _on_run_pressed() -> void:
	pass
	#RNG Running Here
	
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health

func enemy_turn() -> void:
	
	if is_defending:
		is_defending = false
		$AnimationPlayer.play("player_damage")
		await $AnimationPlayer.animation_finished
	else:
		current_player_health = max(
			0,
			current_player_health - enemy.damage
		)
		set_health(
			$GUIMargin/Bottom/Players/MarginContainer/VBoxContainer/BattlePlayerBar/ProgressBar,
			current_player_health,
			State.max_health
		)
		$AnimationPlayer.play("player_damage")
		await $AnimationPlayer.animation_finished


func _on_Enemies_pressed(button: BaseButton) -> void:
	if state != States.TARGETS:
		return

	state = States.BUSY
	disable_all_menus()

	# Player attacks enemy
	current_enemy_health = max(
		0,
		current_enemy_health - State.damage
	)

	set_health(
		$Enemies/BattleEnemy/ProgressBar,
		current_enemy_health,
		enemy.health
	)

	$AnimationPlayer.play("damage")
	await $AnimationPlayer.animation_finished

	# Enemy turn AFTER player animation
	await enemy_turn()

	# Back to player turn
	state = States.OPTIONS
	enable_options_menu()


func disable_all_menus():
	_options_menu.button_enable_focus(false)
	_enemies_menu.button_enable_focus(false)

func enable_options_menu():
	_options_menu.button_enable_focus(true)
	_options_menu.button_focus(0)


func _on_guard_pressed() -> void:
	is_defending = true
	
	enemy_turn()
