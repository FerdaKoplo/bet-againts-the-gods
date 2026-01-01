extends Control

enum States { OPTIONS, TARGETS, BUSY }
@export var enemy: Resource = null

var state: States = States.OPTIONS
var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

# --- REFERENSI NODE ---
@onready var _options_menu = $Options/Options
@onready var boss = $Enemies/BossArachne
@onready var player = $Players/BattlePlayer 
@onready var player_dice = $PlayerDice 
@onready var enemy_dice = $EnemyDice
@export var health_bar_ui: Range

# --- REFERENSI CURSOR YANG SUDAH ADA ---
# Sesuaikan path ini dengan letak cursor kamu di Scene Tree
@onready var menu_cursor = $Options/MenuCursor 

func _ready() -> void:
	# 1. Menu opsi muncul
	_options_menu.show()
	
	# 2. Hubungkan Signal
	if not _options_menu.button_pressed.is_connected(_on_options_button_pressed):
		_options_menu.button_pressed.connect(_on_options_button_pressed)
	
	# 3. Fokus ke tombol pertama
	_options_menu.button_focus(0)
	
	# SETUP SIGNAL (Sudah benar di kode Anda)
	if player.has_signal("health_changed"):
		if not player.health_changed.is_connected(_on_battle_player_health_changed):
			player.health_changed.connect(_on_battle_player_health_changed)
	
	# SETUP AWAL HEALTH BAR
	# Kita set max value saat game mulai
	if health_bar_ui:
		health_bar_ui.max_value = player.max_hp
		health_bar_ui.value = player.hp
	else:
		print("ERROR: Lupa memasukkan node HealthBar ke Inspector 'Battle'!")
	
	print("Battle dimulai! Menunggu input player...")

# --- INPUT UNTUK KONFIRMASI SERANGAN ---
func _input(event: InputEvent) -> void:
	if state == States.TARGETS:
		if event.is_action_pressed("ui_accept"): # Tombol Enter/Spasi/Z
			_confirm_attack()
		elif event.is_action_pressed("ui_cancel"): # Tombol Esc/X
			_cancel_selection()

func start_player_turn():
	print("\n--- GILIRAN PLAYER ---")
	
	# Reset cursor ke mode UI normal jika belum
	if menu_cursor.has_method("reset_to_ui_mode"):
		menu_cursor.reset_to_ui_mode()

	# 1. CEK STATUS PUPPET
	if player.is_controlled():
		print("!!! Player dikendalikan benang Boss!")
		await get_tree().create_timer(1.0).timeout
		player.take_damage(10)
		await get_tree().create_timer(1.0).timeout
		enemy_turn()
		return

	# 2. JIKA NORMAL
	state = States.OPTIONS
	_options_menu.show()
	_options_menu.button_focus(0) # Ini akan memicu cursor otomatis menempel ke tombol

func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			_start_target_selection()
		"Defend":
			print("Player bertahan!")
			state = States.BUSY
			enemy_turn()

# --- LOGIKA TARGETING BARU ---

func _start_target_selection():
	state = States.TARGETS
	
	# Sembunyikan menu opsi
	_options_menu.hide()
	
	# --- PERUBAHAN DI SINI ---
	
	# 1. Hitung titik tengah badan Boss
	# Kita ambil ukuran (size) boss lalu dibagi 2 agar dapat titik tengahnya
	var offset_ke_badan = Vector2(boss.size.x / 14, boss.size.y / 7)
	
	# (Opsional) Jika cursor terlalu menimpa badan, kurangi nilai X agar geser ke kiri sedikit
	# offset_ke_badan.x -= 20 
	
	# 2. Masukkan offset tersebut sebagai parameter kedua
	menu_cursor.point_to_target(boss, offset_ke_badan)

func _confirm_attack():
	state = States.BUSY
	
	# Kembalikan cursor ke mode UI (dia akan hilang sementara sampai menu muncul lagi)
	menu_cursor.reset_to_ui_mode()
	
	_player_attack_boss()

func _cancel_selection():
	# Batal serang, kembali ke menu
	state = States.OPTIONS
	
	menu_cursor.reset_to_ui_mode()
	
	_options_menu.show()
	_options_menu.button_focus(0) # Cursor akan otomatis menempel lagi ke tombol Attack

func _player_attack_boss():
	if player_dice == null: return
	
	print("Mengocok dadu...")
	var roll_result = await player_dice.roll() 
	
	# --- UBAH BAGIAN INI ---
	# LAMA: var final_damage = 20 + (roll_result * 5)
	
	# BARU (Lebih Kecil):
	# Base damage 10, dan setiap angka dadu bernilai 3 damage
	var final_damage = 10 + (roll_result * 3)
	
	print("Hasil dadu: ", roll_result, " | Total Damage: ", final_damage)
	boss.take_damage(final_damage)
	
	await get_tree().create_timer(1.0).timeout
	enemy_turn()

func enemy_turn():
	print("\n--- GILIRAN BOSS ---")
	_options_menu.hide()
	
	var roll_result = await enemy_dice.roll()
	boss.take_turn([player], roll_result)
	
	await get_tree().create_timer(1.5).timeout
	start_player_turn()


func _on_battle_player_health_changed(new_hp, max_hp):
	print("Signal diterima Battle! Update UI ke: ", new_hp)
	
	if health_bar_ui:
		health_bar_ui.value = new_hp
	else:
		print("ERROR: health_bar_ui belum di-assign di Inspector!")
