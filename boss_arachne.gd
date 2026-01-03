extends "res://script/battle_enemy.gd"

# Signal untuk log
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

func take_turn(targets: Array, dice_value: int = 1):
	var boss_luck = max(dice_value, 3) 
	var main_target = targets[0] 
	
	var roll = randf()
	var new_phase = Phase.PHASE_1
	
	if roll < 0.50:
		new_phase = Phase.PHASE_1
		self_modulate = Color(1, 1, 1) # Putih
	elif roll < 0.85:
		new_phase = Phase.PHASE_2
		self_modulate = Color(0.7, 0.4, 1.0) # Ungu
	else:
		new_phase = Phase.PHASE_3
		self_modulate = Color(1.0, 0.3, 0.3) # Merah

	# --- [FITUR BARU] Cek Perubahan Phase ---
	if new_phase != current_active_phase:
		current_active_phase = new_phase
		_announce_phase_change(new_phase)
		# Beri jeda sedikit agar pemain bisa membaca teks perubahan phase
		await get_tree().create_timer(1.0).timeout 
	
	# --- Eksekusi Skill Sesuai Phase ---
	match new_phase:
		Phase.PHASE_1:
			if randf() < 0.3: 
				skill_hujan_jarum(main_target, boss_luck)
			else:
				attack_basic(main_target, boss_luck)
			
		Phase.PHASE_2:
			if randf() < 0.5:
				skill_puppet_master(main_target, boss_luck)
			else:
				var dmg = 12 + boss_luck
				main_target.take_damage(dmg)
				emit_signal("send_log", "Arachne menyerang agresif! -" + str(dmg))
				
		Phase.PHASE_3:
			if randf() < 0.4: 
				skill_unraveling(main_target, boss_luck)
			else:
				var heavy_dmg = 15 + (boss_luck * 2)
				main_target.take_damage(heavy_dmg)
				emit_signal("send_log", "HEAVY ATTACK! -" + str(heavy_dmg))

# Fungsi Helper untuk menampilkan teks Phase
func _announce_phase_change(phase_state):
	match phase_state:
		Phase.PHASE_1:
			emit_signal("send_log", "[color=yellow]Arachne kembali ke posisi Normal.[/color]")
		Phase.PHASE_2:
			emit_signal("send_log", "[color=purple]WARNING: Arachne memasuki Mode Puppet![/color]")
		Phase.PHASE_3:
			emit_signal("send_log", "[color=red]DANGER: Arachne memasuki Mode BERSERK![/color]")

# --- SKILL SET ---
func attack_basic(target, luck):
	var dmg = 8 + (luck * 1.5)
	target.take_damage(dmg)
	emit_signal("send_log", "Arachne mencakar. -" + str(dmg))

func skill_hujan_jarum(target, luck):
	var hits = 3
	var dmg_per_hit = 3 + luck
	var total_dmg = 0
	for i in range(hits):
		target.take_damage(dmg_per_hit)
		total_dmg += dmg_per_hit
	emit_signal("send_log", "Skill: Hujan Jarum! Total -" + str(total_dmg))

func skill_puppet_master(target, luck):
	if luck >= 4:
		target.apply_status("puppet") 
		emit_signal("send_log", "Skill: Puppet Master! Kamu diikat!")
	else:
		target.take_damage(5)
		emit_signal("send_log", "Puppet gagal! -" + str(5) + " HP")

func skill_unraveling(target, luck):
	var fatal_dmg = 30 + (luck * 5) 
	target.take_damage(fatal_dmg)
	emit_signal("send_log", "ULTIMATE: UNRAVELING! -" + str(fatal_dmg))

func check_phase_change():
	pass
