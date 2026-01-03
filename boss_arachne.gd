extends "res://script/battle_enemy.gd"

# Signal untuk mengirim teks ke Battle Log
signal send_log(text_message)

enum Phase { PHASE_1, PHASE_2, PHASE_3 }

# Variabel untuk melacak phase terakhir agar tidak spam log
var current_active_phase = -1 

func _ready():
	super._ready()
	max_hp = 500
	hp = max_hp
	enemy_name = "Weaver Arachne"
	if _atb_bar:
		_atb_bar.max_value = max_hp
		_atb_bar.value = hp

# Fungsi Utama Turn Boss
func take_turn(targets: Array, dice_value: int = 1):
	var main_target = targets[0] 
	
	# --- [FITUR BARU] 1. LOGIKA BOSS CURANG (BOSS BIAS) ---
	var final_luck = dice_value
	
	# Jika dadu asli kecil (1 atau 2), Boss punya kesempatan curang
	if dice_value <= 2:
		# 75% Chance untuk memanipulasi dadu menjadi angka 3-6
		if randf() < 0.75:
			final_luck = randi_range(3, 6) 
			emit_signal("send_log", "Weaver memanipulasi takdir dadu! (" + str(dice_value) + "->" + str(final_luck) + ")")
		else:
			# 25% Chance gagal (Player beruntung)
			emit_signal("send_log", "Arachne gagal mengendalikan takdir... (Dadu: " + str(dice_value) + ")")
	
	# --- 2. LOGIKA PHASE & WARNA ---
	var roll = randf()
	var new_phase = Phase.PHASE_1
	
	if roll < 0.50:
		new_phase = Phase.PHASE_1
		self_modulate = Color(1, 1, 1) # Putih (Normal)
	elif roll < 0.85:
		new_phase = Phase.PHASE_2
		self_modulate = Color(0.7, 0.4, 1.0) # Ungu (Puppet Mode)
	else:
		new_phase = Phase.PHASE_3
		self_modulate = Color(1.0, 0.3, 0.3) # Merah (Berserk)

	# Cek jika Phase berubah
	if new_phase != current_active_phase:
		current_active_phase = new_phase
		_announce_phase_change(new_phase)
		# Beri jeda sedikit agar pemain bisa membaca teks perubahan phase
		await get_tree().create_timer(1.0).timeout 
	
	# --- 3. EKSEKUSI SKILL (Gunakan final_luck) ---
	match new_phase:
		Phase.PHASE_1:
			if randf() < 0.3: 
				skill_hujan_jarum(main_target, final_luck)
			else:
				attack_basic(main_target, final_luck)
			
		Phase.PHASE_2:
			if randf() < 0.5:
				skill_puppet_master(main_target, final_luck)
			else:
				# Serangan agresif dengan scaling
				var multiplier = _get_damage_multiplier(final_luck)
				var base_dmg = 12
				var total_dmg = int(base_dmg * multiplier) + final_luck
				
				main_target.take_damage(total_dmg)
				emit_signal("send_log", "Arachne menyerang agresif! -" + str(total_dmg))
				
		Phase.PHASE_3:
			if randf() < 0.4: 
				skill_unraveling(main_target, final_luck)
			else:
				# Heavy Attack scaling
				var multiplier = _get_damage_multiplier(final_luck)
				var base_dmg = 15
				var total_dmg = int(base_dmg * multiplier) + (final_luck * 2)
				
				main_target.take_damage(total_dmg)
				emit_signal("send_log", "HEAVY ATTACK! -" + str(total_dmg))

# --- FUNGSI HELPER: Scalling Damage ---
# Mengembalikan pengali damage berdasarkan nilai dadu
func _get_damage_multiplier(luck):
	if luck <= 2: return 0.6  # Dadu 1-2: Damage 60% (Lemah)
	if luck <= 4: return 1.0  # Dadu 3-4: Damage 100% (Normal)
	return 1.4                # Dadu 5-6: Damage 140% (Sakit)

# Fungsi Helper untuk menampilkan teks Phase
func _announce_phase_change(phase_state):
	match phase_state:
		Phase.PHASE_1:
			emit_signal("send_log", "[color=yellow]Arachne kembali ke posisi Normal.[/color]")
		Phase.PHASE_2:
			emit_signal("send_log", "[color=purple]WARNING: Arachne memasuki Mode Puppet![/color]")
		Phase.PHASE_3:
			emit_signal("send_log", "[color=red]DANGER: Arachne memasuki Mode BERSERK![/color]")

# --- SKILL SET (Semua damage sudah scaling) ---

func attack_basic(target, luck):
	var multiplier = _get_damage_multiplier(luck)
	var base_dmg = 10
	# Rumus: (Base * Multiplier) + Bonus Dadu
	var total_dmg = int(base_dmg * multiplier) + luck
	
	target.take_damage(total_dmg)
	emit_signal("send_log", "Arachne mencakar. -" + str(total_dmg))

func skill_hujan_jarum(target, luck):
	var hits = 3
	var multiplier = _get_damage_multiplier(luck)
	# Damage per jarum
	var dmg_per_hit = int(3 * multiplier) + int(luck / 2.0)
	var total_dmg = 0
	
	for i in range(hits):
		target.take_damage(dmg_per_hit)
		total_dmg += dmg_per_hit
	
	emit_signal("send_log", "Skill: Hujan Jarum! Total -" + str(total_dmg))

func skill_puppet_master(target, luck):
	# Dadu tinggi (>=4) = Sukses
	# Dadu rendah (<4) = Gagal, damage kecil
	if luck >= 4:
		target.apply_status("puppet") 
		emit_signal("send_log", "Skill: Puppet Master! Kamu diikat!")
	else:
		var dmg = 5 + luck
		target.take_damage(dmg)
		emit_signal("send_log", "Puppet gagal! Boss frustrasi -" + str(dmg) + " HP")

func skill_unraveling(target, luck):
	# Ultimate Skill
	var multiplier = _get_damage_multiplier(luck)
	var fatal_dmg = int(30 * multiplier) + (luck * 4) 
	
	target.take_damage(fatal_dmg)
	emit_signal("send_log", "ULTIMATE: UNRAVELING! -" + str(fatal_dmg))

func check_phase_change():
	pass
