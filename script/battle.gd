extends Control

enum States { OPTIONS, TARGETS }
var state = States.OPTIONS

# --- REFERENSI NODE ---
@onready var _options_menu = $Options/Options
#@onready var _enemies_menu = $Enemies
@onready var boss = $Enemies/BossArachne
@onready var player = $Players/BattlePlayer 
#roll dice
@onready var player_dice = $PlayerDice 
@onready var enemy_dice = $EnemyDice

func _ready() -> void:
	# 1. Pastikan menu opsi muncul
	_options_menu.show()
	
	# 2. HUBUNGKAN SIGNAL DARI MENU (Ini bagian barunya)
	# Artinya: Kalau menu memancarkan sinyal "option_selected", panggil fungsi "_on_options_button_pressed"
	if not _options_menu.option_selected.is_connected(_on_options_button_pressed):
		_options_menu.option_selected.connect(_on_options_button_pressed)
	
	# 3. Fokus ke tombol pertama
	_options_menu.button_focus(0)
	
	print("Battle dimulai! Menunggu input player...")

func start_player_turn():
	print("\n--- GILIRAN PLAYER ---")
	
	# 1. CEK STATUS PUPPET (DIKENDALIKAN)
	if player.is_controlled():
		print("!!! Player dikendalikan benang Boss! Tidak bisa bergerak!")
		
		# Simulasi menyerang diri sendiri
		await get_tree().create_timer(1.0).timeout
		player.take_damage(10) # Player menyakiti diri sendiri
		print("Player melukai dirinya sendiri karena pengaruh Puppet!")
		
		# Langsung oper ke giliran musuh (Skip menu)
		await get_tree().create_timer(1.0).timeout
		enemy_turn()
		return

	# 2. JIKA NORMAL (TIDAK PUPPET)
	# Tampilkan menu agar player bisa memilih
	state = States.OPTIONS
	_options_menu.show()
	_options_menu.button_focus(0)
	# _enemies_menu.hide() # Sesuaikan jika perlu
# --- INPUT / KONTROL MENU ---

func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			_player_attack_boss() # Panggil logika serangan baru
		"Defend":
			print("Player bertahan!")
			enemy_turn()

func _player_attack_boss():
	# 1. Cek apakah node dadu ada sebelum digunakan (Safety Check)
	if player_dice == null:
		print("Error: Node PlayerDice tidak ditemukan di Scene Tree!")
		return
	
	_options_menu.hide()
	print("Player bersiap menyerang... Mengocok dadu!")
	
	# 2. Player kocok dadu dan tunggu hasilnya
	var roll_result = await player_dice.roll() 
	
	# 3. Kalkulasi damage: Base 20 + (Hasil Dadu * 5)
	# Jika dadu 1 = 25 damage, jika dadu 6 = 50 damage
	var final_damage = 20 + (roll_result * 5)
	
	print("Hasil dadu: ", roll_result, " | Total Damage: ", final_damage)
	
	# 4. Berikan damage ke Boss
	boss.take_damage(final_damage)
	
	# 5. Ganti giliran setelah jeda singkat
	await get_tree().create_timer(1.0).timeout
	enemy_turn()

func enemy_turn():
	print("\n--- GILIRAN BOSS ---")
	_options_menu.hide()
	
	# 1. Boss kocok dadu
	var roll_result = await enemy_dice.roll()
	
	# 2. Kirim hasil dadu ke Boss AI agar dia bisa menghitung damage-nya
	# Kita modifikasi fungsi take_turn di boss agar menerima angka dadu
	boss.take_turn([player], roll_result)
	
	await get_tree().create_timer(1.5).timeout
	start_player_turn()
