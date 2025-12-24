extends "res://script/battle_enemy.gd"

# --- DEFINISI FASE ---
enum Phase { PHASE_1, PHASE_2, PHASE_3 }
var current_phase = Phase.PHASE_1

func _ready():
	super._ready() # Jalankan setup dari script dasar
	max_hp = 500   # Boss darahnya tebal
	hp = max_hp
	enemy_name = "Weaver Arachne"

# --- LOGIKA GILIRAN BOSS ---
# Fungsi ini nanti akan dipanggil oleh Battle Manager
func take_turn(targets: Array):
	check_phase_change() # Cek apakah harus ganti fase?
	
	print("\n>>> Giliran " + enemy_name + " (Phase " + str(current_phase) + ") <<<")
	
	match current_phase:
		Phase.PHASE_1:
			# FASE 1: Hujan Jarum (Serang SEMUA target dengan damage kecil)
			print(enemy_name + " menggunakan HUJAN JARUM!")
			for target in targets:
				if target.has_method("take_damage"):
					target.take_damage(5)

		Phase.PHASE_2:
			# FASE 2: Puppet/Minion (Coba kendalikan player acak)
			var target_acak = targets.pick_random()
			print(enemy_name + " menatap " + target_acak.name + "...")
			
			# Cek apakah target punya fungsi 'apply_status'
			if target_acak.has_method("apply_status"):
				print("BOSS: Jadilah bonekaku!")
				target_acak.apply_status("puppet")
			else:
				# Jika tidak bisa dikendalikan, serang biasa
				target_acak.take_damage(15)

		Phase.PHASE_3:
			# FASE 3: Unraveling (Serangan FATAL ke satu target)
			var target_acak = targets.pick_random()
			print(enemy_name + " mengamuk! UNRAVELING pada " + target_acak.name + "!")
			if target_acak.has_method("take_damage"):
				target_acak.take_damage(40) # Damage besar

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
