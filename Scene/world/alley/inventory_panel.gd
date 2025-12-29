extends Panel

@onready var vbox := $VBoxContainer
@onready var title := $VBoxContainer/TitleLabel
@onready var confirm_dialog := $ConfirmUseDialog

var selected_index := 0
var item_list: Array[String] = []
var player
var selected_item := ""
const USABLE_ITEMS = ["Health Potion"]


func _ready():
	visible = false
	player = get_tree().get_first_node_in_group("player")
	confirm_dialog.confirmed.connect(_on_confirmed)

func _unhandled_input(event):
	# Toggle inventory
	if event.is_action_pressed("inventory"):
		visible = !visible
		get_tree().paused = visible
		if visible:
			update_inventory()
		return

	# Abaikan input lain kalau inventory tidak terbuka
	if not visible:
		return

	# Abaikan navigasi kalau inventory kosong
	if item_list.is_empty():
		return

	# Navigasi atas / bawah
	if event.is_action_pressed("ui_down"):
		selected_index = min(selected_index + 1, item_list.size() - 1)
		_refresh_selection()

	elif event.is_action_pressed("ui_up"):
		selected_index = max(selected_index - 1, 0)
		_refresh_selection()

	# ⏎ ENTER / ACCEPT
	elif event.is_action_pressed("interact"):
		var item_name = item_list[selected_index]

		if not USABLE_ITEMS.has(item_name):
			print(item_name, "tidak bisa digunakan")
			return

		selected_item = item_name
		confirm_dialog.dialog_text = "Use %s?" % selected_item
		confirm_dialog.popup_centered()


func update_inventory():
	# Bersihkan UI lama
	for child in vbox.get_children():
		if child != title:
			child.queue_free()

	item_list.clear()
	selected_index = 0

	if player == null:
		return

	if player.inventory.is_empty():
		var label = Label.new()
		label.text = "(Inventory kosong)"
		vbox.add_child(label)
		return

	for item_name in player.inventory.keys():
		item_list.append(item_name)

	_refresh_selection()

func _refresh_selection():
	for child in vbox.get_children():
		if child != title:
			child.queue_free()

	for i in range(item_list.size()):
		var item_name = item_list[i]
		var amount = player.inventory[item_name]

		var label = Label.new()
		if i == selected_index:
			label.text = "> %s x%d" % [item_name, amount]
		else:
			label.text = "  %s x%d" % [item_name, amount]

		vbox.add_child(label)

func _on_confirmed():
	if selected_item == "":
		return

	# ⬅️ TUTUP INVENTORY DULU
	visible = false
	get_tree().paused = false

	player.use_item(selected_item)
	selected_item = ""
	update_inventory()
