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
@onready var menu_cursor = $Options/MenuCursor 

# --- REFERENSI UI LOG (Panel & Text) ---
# Pastikan nama node di Scene Tree sesuai dengan path ini
@onready var log_panel = $PanelContainer 
@onready var log_text = $PanelContainer/battle_log 

func _ready() -> void:
	# 1. Setup Menu
	_options_menu.show()
	if not _options_menu.button_pressed.is_connected(_on_options_button_pressed):
		_options_menu.button_pressed.connect(_on_options_button_pressed)
	_options_menu.button_focus(0)
	
	# 2. Setup Log Panel (Sembunyikan saat awal)
	if log_panel:
		log_panel.hide()
	
	# 3. Konek Signal Boss (PENTING: Agar teks dari Boss muncul di layar)
	if boss.has_signal("send_log"):
		if not boss.is_connected("send_log", _on_log_received):
			boss.connect("send_log", _on_log_received)
	else:
		print("PERINGATAN: BossArachne.gd belum memiliki signal 'send_log'. Update script Boss dulu!")
	
	# 4. Setup Player Signals
	if player.has_signal("health_changed"):
		if not player.health_changed.is_connected(_on_battle_player_health_changed):
			player.health_changed.connect(_on_battle_player_health_changed)
	
	# 5. Setup UI Health Bar
	if health_bar_ui:
		health_bar_ui.max_value = player.max_hp
		health_bar_ui.value = player.hp

# --- FUNGSI TAMPILKAN LOG (FIXED COLOR) ---
func display_log(message: String):
	print("[BATTLE LOG] " + message) # Print ke output bawah untuk debug
	
	if log_panel and log_text:
		log_panel.show()
		log_text.show()
		log_text.text = message 

# Fungsi penerima signal dari Boss
func _on_log_received(msg):
	display_log(msg)

# --- INPUT HANDLING ---
func _input(event: InputEvent) -> void:
	if state == States.TARGETS:
		if event.is_action_pressed("ui_accept"): 
			_confirm_attack()
		elif event.is_action_pressed("ui_cancel"): 
			_cancel_selection()

# --- ALUR TURN PLAYER ---
func start_player_turn():
	print("\n--- GILIRAN BARU ---")
	
	# Reset status defend
	if player.is_defending:
		player.is_defending = false
		print("Posisi bertahan dilepaskan.")
	
	if menu_cursor.has_method("reset_to_ui_mode"):
		menu_cursor.reset_to_ui_mode()

	# 1. CEK STATUS PUPPET (Jika Player dikendalikan Boss)
	if player.is_controlled():
		display_log("!!! Kamu dikendalikan oleh Boss!")
		await get_tree().create_timer(1.5).timeout
		player.take_damage(10)
		
		# Skip turn player, langsung giliran Boss
		_execute_boss_only_turn()
		return

	# 2. JIKA NORMAL
	state = States.OPTIONS
	_options_menu.show()
	_options_menu.button_focus(0)
	
	# Sembunyikan panel log saat menu muncul agar tidak menutupi
	if log_panel: log_panel.hide()

func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			_start_target_selection()
			
		"Guard":
			display_log("Player bersiap menangkis serangan!")
			player.is_defending = true
			state = States.BUSY
			_options_menu.hide()
			
			# Langsung ke giliran boss (tanpa roll dadu player)
			_execute_boss_only_turn()
		
		"Run":
			display_log("Tidak bisa lari dari takdir!")
			await get_tree().create_timer(1.0).timeout
			# Kembali ke menu (gagal lari)
			if log_panel: log_panel.hide()

# --- TARGETING ---
func _start_target_selection():
	state = States.TARGETS
	_options_menu.hide()
	
	# Arahkan kursor ke badan boss (sesuaikan offset jika perlu)
	var offset_ke_badan = Vector2(boss.size.x / 14, boss.size.y / 7)
	menu_cursor.point_to_target(boss, offset_ke_badan)

func _confirm_attack():
	state = States.BUSY
	menu_cursor.reset_to_ui_mode()
	_execute_battle_round()

func _cancel_selection():
	state = States.OPTIONS
	menu_cursor.reset_to_ui_mode()
	_options_menu.show()
	_options_menu.button_focus(0)

# --- LOGIKA BATTLE UTAMA (ATTACK NORMAL) ---
func _execute_battle_round():
	if player_dice == null or enemy_dice == null: return
	
	# 1. Player Roll
	var player_roll = await player_dice.roll()
	
	# 2. Boss Roll
	await get_tree().create_timer(0.5).timeout
	var boss_roll = await enemy_dice.roll()
	
	# Safety check
	if boss_roll == null: boss_roll = 1
	if player_roll == null: player_roll = 1
	
	await get_tree().create_timer(1.5).timeout
	
	# 3. Player Attack Execution
	# Rumus damage: Basic + (Dadu * 3)
	var player_dmg = 10 + (player_roll * 3)
	
	display_log("Player menyerang! -" + str(player_dmg) + " damage")
	boss.take_damage(player_dmg)
	
	# Cek jika Boss kalah
	if boss.hp <= 0:
		await get_tree().create_timer(1.0).timeout
		display_log("VICTORY! Weaver Arachne defeated.")
		boss.queue_free()
		return 

	# 4. Boss Attack Execution
	await get_tree().create_timer(1.5).timeout
	
	# Boss akan mengirim log sendiri via signal saat take_turn dipanggil
	boss.take_turn([player], boss_roll)
	
	# Cek jika Player kalah
	if player.hp <= 0:
		await get_tree().create_timer(1.0).timeout
		display_log("GAME OVER...")
		return

	# 5. Kembali ke Turn Player
	await get_tree().create_timer(2.5).timeout
	start_player_turn()

# --- LOGIKA GUARD (BOSS INSTANT TURN) ---
func _execute_boss_only_turn():
	# Jeda sebentar agar player sempat baca log "Bersiap menangkis"
	await get_tree().create_timer(1.0).timeout
	
	display_log("Boss mengambil kesempatan menyerang!")
	await get_tree().create_timer(1.0).timeout
	
	# Boss roll otomatis '4' saat player guard (tanpa animasi dadu)
	var fixed_boss_roll = 4 
	
	if boss and boss.has_method("take_turn"):
		boss.take_turn([player], fixed_boss_roll)
	
	if player.hp <= 0:
		await get_tree().create_timer(1.0).timeout
		display_log("GAME OVER...")
		return

	await get_tree().create_timer(2.5).timeout
	start_player_turn()

# Update Health Bar
func _on_battle_player_health_changed(new_hp, max_hp):
	if health_bar_ui:
		health_bar_ui.value = new_hp
