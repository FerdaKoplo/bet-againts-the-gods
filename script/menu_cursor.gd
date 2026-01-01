extends TextureRect

const DEFAULT_OFFSET: Vector2 = Vector2(-15, 10) # Ganti nama jadi DEFAULT

var target: Node = null
var is_manual_mode: bool = false
var current_offset: Vector2 = DEFAULT_OFFSET # Variabel untuk menyimpan offset aktif

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_viewport_gui_focus_changed)
	set_process(false)
	
func _process(_delta: float) -> void:
	if target:
		# Gunakan current_offset, bukan konstanta langsung
		global_position = target.global_position + current_offset
	
func _on_viewport_gui_focus_changed(node: Control) -> void:
	if is_manual_mode:
		return

	if node is BaseButton:
		target = node
		current_offset = DEFAULT_OFFSET # Reset ke default untuk tombol UI
		show()
		set_process(true)
	else:
		hide()
		set_process(false)

# --- FUNGSI UPDATE: Tambah parameter offset ---
func point_to_target(new_target: Node, custom_offset: Vector2 = DEFAULT_OFFSET) -> void:
	is_manual_mode = true
	target = new_target
	current_offset = custom_offset # Set jarak khusus
	show()
	set_process(true)

func reset_to_ui_mode() -> void:
	is_manual_mode = false
	current_offset = DEFAULT_OFFSET # Balikin ke default
	hide() 
	set_process(false)
