class_name CardHand
extends PanelContainer

signal selection_changed(selected_cards: Array[CardData], max_selected: int)
signal selection_limit_reached(max_selected: int)
signal refresh_requested

const HAND_CAPACITY := 7
const DEFAULT_MAX_SELECTED := 3
const CARD_WIDTH := 122.0
const CARD_HEIGHT := 172.0
const MAX_CARD_STEP := 110.0
const HOVER_NEIGHBOR_PUSH := 10.0
const CARD_UI_SCENE := preload("res://scenes/crafting/card_ui.tscn")
const PREVIEW_CARDS: Array[CardData] = [
	preload("res://data/cards/batu_asah.tres"),
	preload("res://data/cards/kawat_baja.tres"),
	preload("res://data/cards/amplas.tres"),
	preload("res://data/cards/tenun.tres"),
	preload("res://data/cards/peleburan.tres"),
	preload("res://data/cards/benang.tres"),
	preload("res://data/cards/alat_tenun.tres"),
]

@export var max_selected: int = DEFAULT_MAX_SELECTED

@onready var refresh_button: Button = %RefreshButton
@onready var cards_stage: Control = %CardsStage

var _card_nodes: Array[CardUI] = []
var _selected_nodes: Array[CardUI] = []
var _hovered_index: int = -1
var _initialized_externally: bool = false


func _ready() -> void:
	cards_stage.resized.connect(_on_cards_stage_resized)
	refresh_button.pressed.connect(_on_refresh_pressed)
	call_deferred("_ensure_preview_hand_if_standalone")


func set_hand_cards(cards: Array[CardData], material_stocks: Dictionary = {}) -> void:
	_initialized_externally = true
	_clear_hand()

	var count := mini(cards.size(), HAND_CAPACITY)
	for i in range(count):
		var data := cards[i]
		if data == null:
			continue
		var stock := -1
		if data.category == CardData.Category.MATERIAL:
			stock = int(material_stocks.get(data.card_id, 0))

		var card_ui := CARD_UI_SCENE.instantiate() as CardUI
		cards_stage.add_child(card_ui)
		card_ui.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		card_ui.setup_card(data, stock)
		card_ui.card_clicked.connect(_on_card_clicked)
		card_ui.hover_changed.connect(_on_card_hover_changed)
		_card_nodes.append(card_ui)

	_layout_cards(true)
	call_deferred("_layout_cards", true)
	selection_changed.emit(get_selected_cards(), max_selected)
	if is_node_ready() and count > 0:
		AudioManager.play_sfx(&"card_fan")


func deselect_card_by_index(selection_index: int) -> void:
	if selection_index < 0 or selection_index >= _selected_nodes.size():
		return
	var card_ui := _selected_nodes[selection_index]
	_selected_nodes.remove_at(selection_index)
	if is_instance_valid(card_ui):
		card_ui.set_selected(false)
	selection_changed.emit(get_selected_cards(), max_selected)


func clear_selection() -> void:
	for card_ui in _selected_nodes:
		if is_instance_valid(card_ui):
			card_ui.set_selected(false)
	_selected_nodes.clear()
	selection_changed.emit(get_selected_cards(), max_selected)


func get_selected_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for card_ui in _selected_nodes:
		if is_instance_valid(card_ui) and card_ui.card_data != null:
			result.append(card_ui.card_data)
	return result


func get_selected_count() -> int:
	return _selected_nodes.size()


func get_hand_count() -> int:
	return _card_nodes.size()


func get_card_nodes() -> Array[CardUI]:
	return _card_nodes.duplicate()


func _layout_cards(snap: bool) -> void:
	var total := _card_nodes.size()
	if total == 0:
		return

	var stage_w := cards_stage.size.x
	var stage_h := cards_stage.size.y
	if stage_w <= 0.0:
		stage_w = 760.0
	if stage_h <= 0.0:
		stage_h = 174.0

	var step := MAX_CARD_STEP
	if total > 1:
		var available_span := maxf(0.0, stage_w - CARD_WIDTH - 12.0)
		step = minf(MAX_CARD_STEP, available_span / float(total - 1))

	var total_width := CARD_WIDTH + step * float(maxi(0, total - 1))
	var start_x := (stage_w - total_width) * 0.5
	var base_y := maxf(8.0, (stage_h - CARD_HEIGHT) * 0.5)
	var mid := float(total - 1) * 0.5

	for i in range(total):
		var delta := float(i) - mid
		var push_x := 0.0
		if _hovered_index != -1 and i != _hovered_index:
			var dist := i - _hovered_index
			if dist < 0:
				push_x = -HOVER_NEIGHBOR_PUSH / float(absi(dist))
			else:
				push_x = HOVER_NEIGHBOR_PUSH / float(absi(dist))

		var slot_pos := Vector2(start_x + float(i) * step + push_x, base_y)
		var angle := delta * 1.1
		var arc_y := absf(delta) * 0.7
		_card_nodes[i].set_hand_pose(slot_pos, angle, arc_y, i + 1, snap)


func _ensure_preview_hand_if_standalone() -> void:
	if _initialized_externally or not _card_nodes.is_empty():
		return
	var default_stocks := {
		&"kawat_baja": 2,
		&"benang": 2,
		&"besi_batangan": 2,
	}
	set_hand_cards(PREVIEW_CARDS, default_stocks)


func _clear_hand() -> void:
	_selected_nodes.clear()
	_card_nodes.clear()
	_hovered_index = -1
	for child in cards_stage.get_children():
		cards_stage.remove_child(child)
		child.queue_free()


func _on_cards_stage_resized() -> void:
	_layout_cards(true)


func _on_refresh_pressed() -> void:
	refresh_requested.emit()


func _on_card_hover_changed(card_ui: CardUI, hovered: bool) -> void:
	var idx := _card_nodes.find(card_ui)
	if idx == -1:
		return
	if hovered:
		_hovered_index = idx
	elif _hovered_index == idx:
		_hovered_index = -1
	_layout_cards(false)


func _on_card_clicked(card_ui: CardUI) -> void:
	if card_ui == null or card_ui.is_card_disabled():
		return

	if _selected_nodes.has(card_ui):
		_selected_nodes.erase(card_ui)
		card_ui.set_selected(false)
		AudioManager.play_sfx(&"card_pick", 0.86, 0.92)
		selection_changed.emit(get_selected_cards(), max_selected)
		return

	if _selected_nodes.size() >= max_selected:
		AudioManager.play_sfx(&"ui_click", 0.65, 0.70)
		selection_limit_reached.emit(max_selected)
		return

	_selected_nodes.append(card_ui)
	card_ui.set_selected(true)
	AudioManager.play_sfx(&"card_pick", 1.0, 1.06)
	selection_changed.emit(get_selected_cards(), max_selected)
