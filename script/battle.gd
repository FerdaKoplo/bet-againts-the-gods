#extends Control
#
#enum States {
	#OPTIONS,
	#TARGETS,
#}
#
#var state: States = States.OPTIONS
#
#@onready var _options: WindowDefault = $Options
#@onready var _options_menu: Menu = $Options/Options
#@onready var _enemies_menu: Menu = $Enemies
#
#func _ready() -> void:
	#_options_menu.button_focus(0)
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#match state:
			#States.OPTIONS:
				#pass
			#States.TARGETS:
				#state = States.OPTIONS
				#_options_menu.button_focus()
	#
#func _on_options_button_focused(button: BaseButton) -> void:
	#pass
	#
#func _on_options_button_pressed(button: BaseButton) -> void:
	#match button.text:
		#"Attack":
			#state = States.TARGETS
			#_enemies_menu.button_focus()
			#
extends Control

enum States { OPTIONS, TARGETS }
var state = States.OPTIONS

# --- REFERENSI NODE ---
@onready var _options_menu = $Options/Options
@onready var _enemies_menu = $Enemies
@onready var boss = $Enemies/BossArachne
@onready var player = $Players/BattlePlayer 

func _ready() -> void:
	# Sembunyikan menu target musuh di awal
	# (Jika $Enemies itu wadah musuh visual, mungkin jangan di-hide seluruhnya. 
	#  Tapi kalau itu menu pilihan nama musuh, harus di-hide.)
	# _enemies_menu.hide() 
	
	# Kita pastikan menu opsi muncul
	_options_menu.show()
	_options_menu.button_focus(0)
	
	print("Battle dimulai!")

# --- SYSTEM GILIRAN (TURN SYSTEM) ---

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

func enemy_turn():
	print("\n--- GILIRAN MUSUH ---")
	# Sembunyikan menu opsi saat musuh mikir
	_options_menu.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	# Panggil AI Boss yang sudah kita buat
	# Boss akan otomatis pilih skill berdasarkan Phase-nya
	boss.take_turn([player])
	
	# Kembalikan ke giliran player
	await get_tree().create_timer(1.5).timeout
	start_player_turn()

# --- INPUT / KONTROL MENU ---

func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			# Pindah ke mode memilih target
			# Karena cuma ada 1 boss, kita buat simpel: langsung serang saja
			# (Nanti bisa dikembangkan kalau musuhnya banyak)
			print("Player memilih Attack -> Menyerang Boss!")
			_player_attack_boss()
			
		"Defend":
			print("Player bertahan!")
			enemy_turn()

func _player_attack_boss():
	# Player menyerang Boss
	boss.take_damage(20) # Damage player (bisa diganti stat asli)
	
	# Selesai nyerang, ganti giliran musuh
	enemy_turn()
