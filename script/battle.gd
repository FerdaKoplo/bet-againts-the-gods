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

# --- [BARU] Tambahan variabel untuk menghitung turn musuh ---
var enemy_turn_count = 0 
# ------------------------------------------------------------

# Node Reference untuk UI
#@onready var _options: WindowDefault = $Options 
@onready var _options_menu: Menu = $Options/Options
@onready var _enemies_menu: Menu = $Enemies

# Node Reference untuk Dadu 
@onready var player_dice = $PlayerDice
@onready var enemy_dice = $EnemyDice

#panel text
@onready var log_panel = $PanelContainer
@onready var battle_log = $PanelContainer/battle_log

func _ready() -> void:
	_options_menu.button_focus(0)
	log_panel.visible = false
	battle_log.get_v_scroll_bar().modulate.a = 0
	
	# Setup Health Musuh
	set_health($Enemies/BattleEnemy/ProgressBar, enemy.health, enemy.health)
	
	# Setup Health Player (Mengambil dari Autoload 'State')
	set_health($GUIMargin/Bottom/Players/MarginContainer/VBoxContainer/BattlePlayerBar/ProgressBar, State.current_health, State.max_health)
	
	_options_menu.connect_to_buttons(self)
	_enemies_menu.connect_to_buttons(self)
	# $Enemies/BattleEnemy.texture = enemy.texture 
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	#add_log("--- Pertarungan Dimulai! ---")
	# Reset turn count saat mulai battle
	enemy_turn_count = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state = States.OPTIONS
				_options_menu.button_focus()
	
func _on_options_button_focused(_button: BaseButton) -> void:
	pass
	
func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			state = States.TARGETS
			_enemies_menu.button_focus()
			
func _on_run_pressed() -> void:
	print("Mencoba lari...")
	# Tambahkan logika kabur di sini

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health

# --- [BARU] FUNGSI GILIRAN MUSUH DENGAN PATTERN ---
func enemy_turn() -> void:
	if current_enemy_health <= 0:
		return

	enemy_turn_count += 1
	add_log("\n--- Giliran Musuh ke-" + str(enemy_turn_count) + " ---") # Pakai str() untuk gabung angka

	var action_type = "normal"
	var damage_multiplier = 1.0

	# --- LOGIKA POLA ---
	if float(current_enemy_health) / float(enemy.health) < 0.2 and randf() < 0.4:
		action_type = "heal"
	elif enemy_turn_count % 3 == 0:
		action_type = "skill_heavy"
		damage_multiplier = 2.0
	else:
		var roll = randf()
		if roll < 0.7:
			action_type = "normal"
			damage_multiplier = 1.0
		elif roll < 0.9:
			action_type = "quick"
			damage_multiplier = 0.8
		else:
			action_type = "prepare"
			damage_multiplier = 0.0

	# --- EKSEKUSI ---
	if action_type == "heal":
		var heal_amount = int(enemy.health * 0.25)
		current_enemy_health = min(enemy.health, current_enemy_health + heal_amount)
		
		add_log("Musuh panik dan meminum Potion! HP pulih.") # GANTI PRINT
		
		set_health($Enemies/BattleEnemy/ProgressBar, current_enemy_health, enemy.health)
		await get_tree().create_timer(1.0).timeout

	elif action_type == "prepare":
		add_log("Musuh sedang memasang kuda-kuda... (Giliran lewat)") # GANTI PRINT
		await get_tree().create_timer(1.0).timeout

	else:
		var final_damage = enemy.damage * damage_multiplier
		
		if action_type == "skill_heavy":
			add_log("!!! MUSUH MENGELUARKAN JURUS ULTIMATE !!!") # GANTI PRINT
		elif action_type == "quick":
			add_log("Musuh menyerang dengan cepat!") # GANTI PRINT
		else:
			add_log("Musuh menyerang biasa.") # GANTI PRINT

		if is_defending:
			is_defending = false
			final_damage = final_damage * 0.5
			add_log("Player menangkis! Damage berkurang.") # GANTI PRINT

		if final_damage > 0:
			current_player_health = max(0, current_player_health - int(final_damage))
			add_log("Player terkena " + str(int(final_damage)) + " damage!") # Info Damage
			
			set_health(
				$GUIMargin/Bottom/Players/MarginContainer/VBoxContainer/BattlePlayerBar/ProgressBar,
				current_player_health,
				State.max_health
			)
			State.current_health = current_player_health
			
			# Animasi
			if $AnimationPlayer.has_animation("player_damage"):
				$AnimationPlayer.play("player_damage")
			
			await $AnimationPlayer.animation_finished
# ---------------------------------------------------------

# Fungsi saat Player memilih musuh untuk diserang
func _on_Enemies_pressed(_button: BaseButton) -> void:
	if state != States.TARGETS:
		return

	state = States.BUSY
	disable_all_menus()

	# --- MULAI LOGIKA DADU ---
	print("Memulai lemparan dadu...")
	
	# Jalankan animasi dadu 
	var player_roll_value = await player_dice.roll()
	var enemy_roll_value = await enemy_dice.roll()
	
	print("Hasil -> Player: ", player_roll_value, " VS Musuh: ", enemy_roll_value)
	
	# 2. Bandingkan Nilai
	if player_roll_value > enemy_roll_value:
		# --- PLAYER MENANG (Attack Berhasil) ---
		print("Attack Berhasil! Musuh terkena damage.")
		var final_damage = State.damage
		var critical_chance = 0.5
		if randf() <= critical_chance:
			final_damage = final_damage * 3 # Damage dikali 3 (ORIGINAL)
			print("!!! CRITICAL HIT !!! Damage menjadi: ", final_damage)
		else:
			print("Normal Hit. Damage: ", final_damage)
			
		current_enemy_health = max(0, current_enemy_health - final_damage)
		State.current_health = current_player_health # Typo fix dari kodemu sebelumnya (biasanya ini tidak perlu diupdate saat nyerang, tapi saya biarkan sesuai aslinya)
		
		set_health(
			$Enemies/BattleEnemy/ProgressBar,
			current_enemy_health,
			enemy.health
		)
		
		# Panggil animasi MUSUH sakit ("damage")
		$AnimationPlayer.play("damage")
		await $AnimationPlayer.animation_finished

	elif player_roll_value < enemy_roll_value:
		# --- PLAYER KALAH (Attack Meleset / Kena Diri Sendiri) ---
		print("Attack Gagal! Player terkena recoil/serangan balik.")
		
		# Contoh: Player kena sedikit damage karena gagal
		var recoil_damage = 10 # (ORIGINAL)
		current_player_health = max(0, current_player_health - recoil_damage)
		State.current_health = current_player_health
		
		# Update UI Health Player
		set_health(
			$GUIMargin/Bottom/Players/MarginContainer/VBoxContainer/BattlePlayerBar/ProgressBar,
			current_player_health,
			State.max_health
		)
		
		# Update data global
		State.current_health = current_player_health
		
		# Panggil animasi PLAYER sakit ("player_damage")
		$AnimationPlayer.play("player_damage")
		await $AnimationPlayer.animation_finished
		
	else:
		# --- SERI (Draw) ---
		print("Seri! Tidak ada damage.")
		# Bisa tambahkan delay sedikit atau efek suara 'clash'
		await get_tree().create_timer(0.5).timeout

	# 3. Lanjut ke Giliran Musuh (Jika musuh masih hidup)
	if current_enemy_health > 0:
		await enemy_turn()
	else:
		print("Musuh Kalah! Battle Selesai.")
		# Tambahkan logika kemenangan di sini

	# Kembali ke menu player
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
	state = States.BUSY
	disable_all_menus()
	
	# Langsung masuk giliran musuh
	await enemy_turn()
	
	state = States.OPTIONS
	enable_options_menu()
	
# Fungsi untuk menampilkan teks ke layar game
func add_log(text: String) -> void:
	# LOGIKA BARU: Jika panel masih sembunyi, munculkan sekarang!
	if log_panel.visible == false:
		log_panel.visible = true
	
	# Lanjut tulis teks seperti biasa
	battle_log.append_text(text + "\n")
	print(text)
