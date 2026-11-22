class_name CraftingScene
extends Control

signal dialogue_requested
signal craft_completed(result: ProcessingResult)

const CARD_UI_SCENE := preload("res://scenes/crafting/card_ui.tscn")
const FONT_GOCHI := preload("res://assets/fonts/Gochi_Hand/GochiHand-Regular.ttf")

const DEFAULT_CARDS: Array[CardData] = [
	preload("res://data/cards/kawat_baja.tres"),
	preload("res://data/cards/benang.tres"),
	preload("res://data/cards/besi_batangan.tres"),
	preload("res://data/cards/amplas.tres"),
	preload("res://data/cards/tenun.tres"),
	preload("res://data/cards/peleburan.tres"),
	preload("res://data/cards/batu_asah.tres"),
	preload("res://data/cards/alat_tenun.tres"),
	preload("res://data/cards/cetakan.tres"),
	preload("res://data/cards/alat_jahit.tres"),
	preload("res://data/cards/kain.tres"),
	preload("res://data/cards/gunting.tres"),
	preload("res://data/cards/baju.tres"),
	preload("res://data/cards/biji_perak.tres"),
	preload("res://data/cards/pasir_silica.tres"),
	preload("res://data/cards/tungku.tres"),
	preload("res://data/cards/perak_batangan.tres"),
	preload("res://data/cards/kaca.tres"),
	preload("res://data/cards/cermin.tres"),
]

const DEFAULT_RECIPES: Array[RecipeData] = [
	preload("res://data/recipes/alat_jahit_recipe.tres"),
	preload("res://data/recipes/kain_recipe.tres"),
	preload("res://data/recipes/gunting_recipe.tres"),
	preload("res://data/recipes/baju_recipe.tres"),
	preload("res://data/recipes/perak_batangan_recipe.tres"),
	preload("res://data/recipes/kaca_recipe.tres"),
	preload("res://data/recipes/cermin_recipe.tres"),
]

const OBJECTIVE_SEQUENCE: Array[StringName] = [
	&"alat_jahit",
	&"kain",
	&"gunting",
	&"baju",
]

const STORAGE_OUTPUT_IDS: Array[StringName] = [
	&"alat_jahit",
	&"kain",
	&"gunting",
	&"baju",
	&"perak_batangan",
	&"kaca",
	&"cermin",
]

const OBJECTIVE_DECK_POOLS: Dictionary = {
	&"alat_jahit": [
		&"batu_asah",
		&"kawat_baja",
		&"amplas",
		&"tenun",
		&"peleburan",
		&"benang",
		&"alat_tenun",
	],
	&"kain": [
		&"alat_tenun",
		&"benang",
		&"tenun",
		&"amplas",
		&"peleburan",
		&"besi_batangan",
		&"cetakan",
	],
	&"gunting": [
		&"cetakan",
		&"besi_batangan",
		&"peleburan",
		&"amplas",
		&"tenun",
		&"kawat_baja",
		&"batu_asah",
	],
	&"baju": [
		&"batu_asah",
		&"kawat_baja",
		&"amplas",
		&"tenun",
		&"peleburan",
		&"benang",
		&"alat_tenun",
	],
}

@export var card_catalog: Array[CardData] = []
@export var recipes: Array[RecipeData] = []

@onready var inventory_manager: InventoryManager = %InventoryManager
@onready var settings_button: Button = %SettingsButton
@onready var book_button: Button = %BookButton
@onready var stage_feedback_label: Label = %StageFeedbackLabel
@onready var you_get_frame: PanelContainer = %YouGetFrame
@onready var you_get_item_texture: TextureRect = %YouGetItemTexture
@onready var you_get_star_label: Label = %YouGetStarLabel
@onready var you_get_item_label: Label = %YouGetItemLabel
@onready var combine_slot_0: Button = %CombineSlot0
@onready var combine_slot_1: Button = %CombineSlot1
@onready var combine_slot_2: Button = %CombineSlot2
@onready var combine_button: Button = %CombineButton
@onready var card_hand: CardHand = %CardHand
@onready var objective_item_texture: TextureRect = %ObjectiveItemTexture
@onready var objective_target_label: Label = %ObjectiveTargetLabel
@onready var inventory_hint_label: Label = %InventoryHintLabel
@onready var inventory_items_flow: HFlowContainer = %InventoryItemsFlow
@onready var settings_popup: Control = %SettingsPopup
@onready var mute_check_button: CheckButton = %MuteCheckButton
@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value_label: Label = %VolumeValueLabel
@onready var settings_book_button: Button = %SettingsBookButton
@onready var back_to_dialogue_button: Button = %BackToDialogueButton
@onready var close_settings_button: Button = %CloseSettingsButton
@onready var book_popup: Control = %BookPopup
@onready var left_page_text: RichTextLabel = %LeftPageText
@onready var right_page_text: RichTextLabel = %RightPageText
@onready var close_book_button: Button = %CloseBookButton

var _processor := CraftingProcessor.new()
var _current_objective_index: int = 0
var _deck_injected_items: Array[StringName] = []
var _current_hand_ids: Array[StringName] = []
var _combine_slots: Array[Button] = []


func _ready() -> void:
	if card_catalog.is_empty():
		card_catalog = DEFAULT_CARDS.duplicate()
	if recipes.is_empty():
		recipes = DEFAULT_RECIPES.duplicate()

	_combine_slots = [combine_slot_0, combine_slot_1, combine_slot_2]
	for i in range(_combine_slots.size()):
		var slot_btn := _combine_slots[i]
		slot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var slot_idx := i
		slot_btn.pressed.connect(func() -> void: _on_combine_slot_pressed(slot_idx))

	inventory_manager.register_cards(card_catalog)
	inventory_manager.setup_initial_inventory(
		{
			&"kawat_baja": 3,
			&"benang": 3,
			&"besi_batangan": 3,
		},
		[&"amplas", &"tenun", &"peleburan"],
		[&"batu_asah", &"alat_tenun", &"cetakan"]
	)

	card_hand.max_selected = 3
	card_hand.selection_changed.connect(_on_hand_selection_changed)
	card_hand.selection_limit_reached.connect(_on_hand_selection_limit_reached)
	card_hand.refresh_requested.connect(_on_card_hand_refresh_requested)
	combine_button.pressed.connect(_on_combine_pressed)
	settings_button.pressed.connect(open_settings_popup)
	book_button.pressed.connect(open_book_popup)

	mute_check_button.toggled.connect(_on_mute_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_book_button.pressed.connect(_on_settings_book_pressed)
	back_to_dialogue_button.pressed.connect(_on_back_to_dialogue_pressed)
	close_settings_button.pressed.connect(close_settings_popup)
	close_book_button.pressed.connect(close_book_popup)

	_sync_audio_controls_from_server()
	_refresh_objective_and_book()
	_refresh_inventory_panel()
	_refresh_hand(false)
	_update_combine_stage([])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if book_popup.visible:
			close_book_popup()
			get_viewport().set_input_as_handled()
		elif settings_popup.visible:
			close_settings_popup()
			get_viewport().set_input_as_handled()
		else:
			open_settings_popup()
			get_viewport().set_input_as_handled()


func get_current_objective_id() -> StringName:
	if _current_objective_index < 0 or _current_objective_index >= OBJECTIVE_SEQUENCE.size():
		return &"baju"
	return OBJECTIVE_SEQUENCE[_current_objective_index]


func send_inventory_item_to_deck(card_id: StringName) -> bool:
	if not inventory_manager.has_material(card_id, 1):
		return false
	if not _deck_injected_items.has(card_id):
		_deck_injected_items.append(card_id)
	var card := inventory_manager.get_card(card_id)
	var card_name := card.display_name if card != null else String(card_id)
	stage_feedback_label.text = "'%s' dimasukkan dari penyimpanan ke deck bawah." % card_name
	_refresh_inventory_panel()
	_refresh_hand(false)
	return true


func craft_selected_cards() -> ProcessingResult:
	var selected := card_hand.get_selected_cards()
	var result := _processor.execute(selected, recipes, inventory_manager)

	if result.status == ProcessingResult.Status.VALIDATION_ERROR:
		stage_feedback_label.text = result.reason
		_apply_preview_visual("!", "Belum Cocok", null, Color("#1E1610"))
		craft_completed.emit(result)
		return result

	var out_id: StringName = result.output_ids[0] if not result.output_ids.is_empty() else &""
	var out_card := inventory_manager.get_card(out_id)
	var out_name := out_card.display_name if out_card != null else String(out_id)
	var out_icon: Texture2D = out_card.icon if out_card != null else null

	# Keep starter raw materials replenished so experimentation never soft-locks the tutorial.
	for base_id in [&"kawat_baja", &"benang", &"besi_batangan"]:
		if inventory_manager.get_material_count(base_id) <= 0:
			inventory_manager.add_material(base_id, 1)

	var remaining_injected: Array[StringName] = []
	for injected_id in _deck_injected_items:
		if inventory_manager.has_material(injected_id, 1):
			remaining_injected.append(injected_id)
	_deck_injected_items = remaining_injected

	_advance_objective_if_matched(out_id)
	_refresh_objective_and_book()
	_refresh_inventory_panel()
	_refresh_hand(false)

	_apply_preview_visual("*", out_name, out_icon, Color("#2E7D32"))
	stage_feedback_label.text = "Berhasil membuat '%s'! Item masuk ke penyimpanan." % out_name
	craft_completed.emit(result)
	return result


func open_settings_popup() -> void:
	book_popup.visible = false
	_sync_audio_controls_from_server()
	settings_popup.visible = true
	close_settings_button.grab_focus()


func close_settings_popup() -> void:
	settings_popup.visible = false
	settings_button.grab_focus()


func open_book_popup() -> void:
	settings_popup.visible = false
	_refresh_objective_and_book()
	book_popup.visible = true
	close_book_button.grab_focus()


func close_book_popup() -> void:
	book_popup.visible = false
	book_button.grab_focus()


func _advance_objective_if_matched(crafted_output_id: StringName) -> void:
	if crafted_output_id == get_current_objective_id():
		if _current_objective_index < OBJECTIVE_SEQUENCE.size() - 1:
			_current_objective_index += 1
		return

	for i in range(OBJECTIVE_SEQUENCE.size()):
		var obj_id := OBJECTIVE_SEQUENCE[i]
		if not inventory_manager.has_material(obj_id, 1):
			_current_objective_index = i
			return
	_current_objective_index = OBJECTIVE_SEQUENCE.size() - 1


func _collect_available_pool_ids() -> Array[StringName]:
	var pool: Array[StringName] = []
	for card in inventory_manager.get_available_materials():
		if not pool.has(card.card_id):
			pool.append(card.card_id)
	for card in inventory_manager.get_available_processes():
		if not pool.has(card.card_id):
			pool.append(card.card_id)
	for card in inventory_manager.get_available_tools():
		if not pool.has(card.card_id):
			pool.append(card.card_id)
	return pool


func _build_balanced_deck_ids(shuffle_pool: bool) -> Array[StringName]:
	var deck_ids: Array[StringName] = []

	for injected_id in _deck_injected_items:
		if deck_ids.size() >= CardHand.HAND_CAPACITY:
			break
		if inventory_manager.has_material(injected_id, 1) and not deck_ids.has(injected_id):
			deck_ids.append(injected_id)

	if shuffle_pool:
		var candidates: Array[StringName] = []
		for cid in _collect_available_pool_ids():
			if not deck_ids.has(cid):
				candidates.append(cid)
		candidates.shuffle()

		var candidate_hand: Array[StringName] = deck_ids.duplicate()
		for cid in candidates:
			if candidate_hand.size() >= CardHand.HAND_CAPACITY:
				break
			candidate_hand.append(cid)

		# Rotate once if random shuffle happens to match the exact previous hand order.
		if candidate_hand == _current_hand_ids and candidates.size() > 1:
			candidates.append(candidates.pop_front())
			candidate_hand = deck_ids.duplicate()
			for cid in candidates:
				if candidate_hand.size() >= CardHand.HAND_CAPACITY:
					break
				candidate_hand.append(cid)

		return candidate_hand

	var current_obj := get_current_objective_id()
	var base_pool: Array = OBJECTIVE_DECK_POOLS.get(current_obj, OBJECTIVE_DECK_POOLS[&"alat_jahit"])
	for raw_id in base_pool:
		if deck_ids.size() >= CardHand.HAND_CAPACITY:
			break
		var cid := StringName(raw_id)
		if not deck_ids.has(cid):
			deck_ids.append(cid)

	return deck_ids


func _refresh_hand(shuffle_pool: bool) -> void:
	var deck_ids := _build_balanced_deck_ids(shuffle_pool)
	_current_hand_ids = deck_ids.duplicate()
	var hand_cards := inventory_manager.get_curated_hand_cards(deck_ids, CardHand.HAND_CAPACITY)
	card_hand.set_hand_cards(hand_cards, inventory_manager.get_material_stocks_snapshot())


func _refresh_objective_and_book() -> void:
	var current_obj := get_current_objective_id()
	var obj_card := inventory_manager.get_card(current_obj)
	var obj_name := obj_card.display_name if obj_card != null else String(current_obj)

	if inventory_manager.has_material(&"baju", 1):
		objective_target_label.text = "Baju (Selesai!)"
	else:
		objective_target_label.text = obj_name

	var obj_center := objective_item_texture.get_parent() as Control
	if obj_card != null and obj_card.icon != null:
		objective_item_texture.texture = obj_card.icon
		objective_item_texture.visible = true
		if obj_center != null:
			obj_center.visible = true
		objective_target_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		objective_target_label.add_theme_font_size_override("font_size", 21)
	elif obj_card != null and obj_card.card_texture != null:
		objective_item_texture.texture = obj_card.card_texture
		objective_item_texture.visible = true
		if obj_center != null:
			obj_center.visible = true
		objective_target_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		objective_target_label.add_theme_font_size_override("font_size", 21)
	else:
		objective_item_texture.texture = null
		objective_item_texture.visible = false
		if obj_center != null:
			obj_center.visible = false
		objective_target_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		objective_target_label.add_theme_font_size_override("font_size", 28)

	left_page_text.text = (
		"Bahan Setengah Jadi:\n\n"
		+ "1. Alat Jahit\n"
		+ "   Kawat Baja + Amplas + Batu Asah\n\n"
		+ "2. Kain\n"
		+ "   Benang + Tenun + Alat Tenun\n\n"
		+ "3. Gunting\n"
		+ "   Besi Batangan + Peleburan + Cetakan"
	)

	var has_aj := "v" if inventory_manager.has_material(&"alat_jahit", 1) else " "
	var has_kn := "v" if inventory_manager.has_material(&"kain", 1) else " "
	var has_gt := "v" if inventory_manager.has_material(&"gunting", 1) else " "

	right_page_text.text = (
		"Aturan Bahan Jadi:\n\n"
		+ "BAJU =\n"
		+ "[%s] Alat Jahit\n"
		+ "[%s] Kain\n"
		+ "[%s] Gunting\n\n"
		+ "Alur:\n"
		+ "Hasil combine masuk ke Penyimpanan. Klik kartu mini di Penyimpanan agar masuk ke Deck Bawah."
	) % [has_aj, has_kn, has_gt]


func _refresh_inventory_panel() -> void:
	for child in inventory_items_flow.get_children():
		inventory_items_flow.remove_child(child)
		child.queue_free()

	var total_items := 0
	for item_id in STORAGE_OUTPUT_IDS:
		var count := inventory_manager.get_material_count(item_id)
		if count <= 0:
			continue
		total_items += 1
		var card := inventory_manager.get_card(item_id)
		var item_name := card.display_name if card != null else String(item_id)
		var in_deck := _deck_injected_items.has(item_id)

		var btn := _create_storage_mini_card_button(card, item_name, count, in_deck)
		var captured_id := item_id
		btn.pressed.connect(func() -> void: send_inventory_item_to_deck(captured_id))
		inventory_items_flow.add_child(btn)

	inventory_hint_label.visible = total_items == 0


func _create_storage_mini_card_button(
	card: CardData,
	item_name: String,
	count: int,
	in_deck: bool
) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(90, 126)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.tooltip_text = "%s (x%d) - Klik untuk memasukkan ke deck bawah" % [item_name, count]

	var normal := StyleBoxFlat.new()
	normal.draw_center = false
	normal.set_corner_radius_all(10)
	if in_deck:
		normal.border_color = Color("#FFE45E")
		normal.set_border_width_all(3)

	var hover := StyleBoxFlat.new()
	hover.draw_center = false
	hover.border_color = Color("#FFF8EE")
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(10)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", hover)

	if card != null:
		var mini_card := CARD_UI_SCENE.instantiate() as CardUI
		mini_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		btn.add_child(mini_card)
		mini_card.set_static_display(card, count, true)

	if in_deck:
		var badge := Label.new()
		badge.text = "Di Deck"
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		badge.offset_top = -22.0
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_font_override("font", FONT_GOCHI)
		badge.add_theme_font_size_override("font_size", 13)
		badge.add_theme_color_override("font_color", Color("#1A120B"))

		var badge_bg := PanelContainer.new()
		badge_bg.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		badge_bg.offset_left = 6.0
		badge_bg.offset_right = -6.0
		badge_bg.offset_top = -24.0
		badge_bg.offset_bottom = -4.0
		badge_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bg_style := StyleBoxFlat.new()
		bg_style.bg_color = Color("#FFE45E")
		bg_style.set_corner_radius_all(8)
		badge_bg.add_theme_stylebox_override("panel", bg_style)
		badge_bg.add_child(badge)
		btn.add_child(badge_bg)

	return btn


func _update_combine_stage(selected_cards: Array[CardData]) -> void:
	for i in range(_combine_slots.size()):
		var slot_btn := _combine_slots[i]
		var empty_tpl := slot_btn.get_node_or_null("EmptyTemplate") as TextureRect
		var slot_card_view := slot_btn.get_node_or_null("SlotCardView") as CardUI

		if i < selected_cards.size() and selected_cards[i] != null:
			var card := selected_cards[i]
			slot_btn.disabled = false
			slot_btn.tooltip_text = "%s - Klik untuk melepas kartu" % card.display_name
			if empty_tpl != null:
				empty_tpl.visible = false
			if slot_card_view != null:
				slot_card_view.visible = true
				slot_card_view.set_static_display(card, -1)
		else:
			slot_btn.disabled = true
			slot_btn.tooltip_text = "Slot %d kosong" % (i + 1)
			if empty_tpl != null:
				empty_tpl.visible = true
			if slot_card_view != null:
				slot_card_view.visible = false

	combine_button.disabled = selected_cards.is_empty()

	if selected_cards.is_empty():
		_apply_preview_visual("?", "Pilih Kartu", null, Color("#1E1610"))
		return

	var preview_result := _processor.validate_selection(selected_cards, recipes, inventory_manager)
	if preview_result.status == ProcessingResult.Status.SUCCESS and not preview_result.output_ids.is_empty():
		var out_card := inventory_manager.get_card(preview_result.output_ids[0])
		var out_name := out_card.display_name if out_card != null else String(preview_result.output_ids[0])
		var out_icon: Texture2D = out_card.icon if out_card != null else null
		_apply_preview_visual("*", out_name, out_icon, Color("#1E1610"))
		stage_feedback_label.text = "Kombinasi cocok! Tekan 'combine' untuk membuat '%s'." % out_name
	elif selected_cards.size() < 3:
		_apply_preview_visual("...", "%d / 3 Kartu" % selected_cards.size(), null, Color("#1E1610"))
		stage_feedback_label.text = "Pilih %d kartu lagi dari deck bawah." % (3 - selected_cards.size())
	else:
		_apply_preview_visual("?", "Belum Sesuai", null, Color("#1E1610"))
		stage_feedback_label.text = "3 kartu di tengah belum cocok dengan resep. Klik kartu tengah untuk mengganti."


func _apply_preview_visual(
	symbol_text: String,
	item_text: String,
	item_icon: Texture2D,
	border_color: Color
) -> void:
	you_get_item_label.text = item_text
	if item_icon != null:
		you_get_item_texture.texture = item_icon
		you_get_item_texture.visible = true
		you_get_star_label.visible = false
	else:
		you_get_item_texture.texture = null
		you_get_item_texture.visible = false
		you_get_star_label.text = symbol_text
		you_get_star_label.visible = true

	var style := StyleBoxFlat.new()
	style.bg_color = Color("#FFCC00")
	style.border_color = border_color
	style.set_border_width_all(4)
	style.set_corner_radius_all(14)
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 6
	style.shadow_offset = Vector2(-4, 6)
	you_get_frame.add_theme_stylebox_override("panel", style)


func _get_target_audio_bus_index() -> int:
	var music_idx := AudioServer.get_bus_index("Music")
	return music_idx if music_idx >= 0 else 0


func _sync_audio_controls_from_server() -> void:
	var bus_idx := _get_target_audio_bus_index()
	var is_muted := AudioServer.is_bus_mute(bus_idx)
	var linear := clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_idx)), 0.0, 1.0)
	mute_check_button.set_pressed_no_signal(is_muted)
	volume_slider.set_value_no_signal(linear)
	volume_value_label.text = "%d%%" % roundi(linear * 100.0)


func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(_get_target_audio_bus_index(), toggled_on)


func _on_volume_changed(value: float) -> void:
	var clamped := clampf(value, 0.0, 1.0)
	var bus_idx := _get_target_audio_bus_index()
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(maxf(clamped, 0.0001)))
	AudioServer.set_bus_mute(bus_idx, clamped <= 0.001)
	mute_check_button.set_pressed_no_signal(AudioServer.is_bus_mute(bus_idx))
	volume_value_label.text = "%d%%" % roundi(clamped * 100.0)


func _on_card_hand_refresh_requested() -> void:
	_refresh_hand(true)
	stage_feedback_label.text = "Kartu di deck bawah diacak ulang dari pool yang tersedia."


func _on_hand_selection_changed(selected_cards: Array[CardData], _max_selected: int) -> void:
	_update_combine_stage(selected_cards)


func _on_hand_selection_limit_reached(max_sel: int) -> void:
	stage_feedback_label.text = "Area combine tengah maksimal menampung %d kartu. Klik kartu tengah untuk melepas." % max_sel


func _on_combine_slot_pressed(slot_index: int) -> void:
	card_hand.deselect_card_by_index(slot_index)


func _on_combine_pressed() -> void:
	craft_selected_cards()


func _on_settings_book_pressed() -> void:
	open_book_popup()


func _on_back_to_dialogue_pressed() -> void:
	dialogue_requested.emit()
