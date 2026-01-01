extends "res://script/battle_enemy.gd"

# --- DEFINISI FASE ---
enum Phase { PHASE_1, PHASE_2, PHASE_3 }
var current_phase = Phase.PHASE_1

func _ready():
	super._ready() # 1. Ini menjalankan setup awal (set bar ke 100/100)
	
	# 2. Kita timpa nilai HP untuk Boss
	max_hp = 500
	hp = max_hp
	enemy_name = "Weaver Arachne"
	
	# --- TAMBAHAN PENTING ---
	# Update ulang Health Bar agar sesuai dengan 500 HP, bukan 100
	if _atb_bar:
		_atb_bar.max_value = max_hp
		_atb_bar.value = hp

# --- LOGIKA GILIRAN BOSS ---
# Fungsi ini nanti akan dipanggil oleh Battle Manager
func take_turn(targets: Array, dice_value: int = 1):
	check_phase_change()
	
	# Boss Advantage: Jika dadu boss < 3, paksa jadi 3 (Boss tidak pernah terlalu lemah)
	var boss_luck = max(dice_value, 3) 
	
	match current_phase:
		Phase.PHASE_1:
			var dmg = 10 + (boss_luck * 2) # Damage stabil
			targets[0].take_damage(dmg)
			
		Phase.PHASE_2:
			# Peluang mengendalikan player lebih tinggi jika dadu besar
			if boss_luck >= 5:
				targets[0].apply_status("puppet")
			else:
				targets[0].take_damage(15)
				
		Phase.PHASE_3:
			# Serangan mematikan: Damage dasar besar + bonus dadu
			var fatal_dmg = 30 + (boss_luck * 5) 
			targets[0].take_damage(fatal_dmg)

# --- CEK PERGANTIAN FASE ---
func check_phase_change():
	var hp_persen = (float(hp) / float(max_hp)) * 100.0
	
	# Jika darah < 30% -> Masuk Phase 3
	if hp_persen < 30.0 and current_phase != Phase.PHASE_3:
		current_phase = Phase.PHASE_3
		print("BOSS ROAR: Benang takdirmu putus di sini! (PHASE 3 START)")
	
	# Jika darah < 60% -> Masuk Phase 2
	elif hp_persen < 60.0 and current_phase != Phase.PHASE_2:
		current_phase = Phase.PHASE_2
		print("BOSS LAUGH: Menarilah untukku! (PHASE 2 START)")
