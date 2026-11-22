class_name CraftingScene
extends Control

signal dialogue_requested
signal craft_completed(result: ProcessingResult)

enum TutorialPhase {
	INTRO_DIALOGUE,
	WAIT_SELECT_CARDS,
	PREVIEW_EXPLAIN_DIALOGUE,
	WAIT_PRESS_COMBINE,
	AFTER_FIRST_CRAFT_DIALOGUE,
	WAIT_ALL_INTERMEDIATES,
	READY_FOR_BAJU_DIALOGUE,
	WAIT_CRAFT_BAJU,
	COMPLETED,
}

const CARD_UI_SCENE := preload("res://scenes/crafting/card_ui.tscn")
const FONT_GOCHI := preload("res://assets/fonts/Gochi_Hand/GochiHand-Regular.ttf")
const PLAYER_SPRITE_TEX := preload("res://assets/sprites/player/senyum hmm.png")
const RAIL_SPRITE_TEX := preload("res://assets/sprites/alien/Rail flat.png")
const BAJU_CARD_TEX := preload("res://assets/card/Baju.png")
const CERMIN_CARD_TEX := preload("res://assets/card/Cermin.png")
const LIPSTIK_CARD_TEX := preload("res://assets/card/Lipstik.png")

const INTRO_TUTORIAL_LINES: Array[Dictionary] = [
	{
		"speaker": "ilmuan",
		"highlight": "slots",
		"text": "Oke, jadi ini adalah meja kerja kita. Kita akan membuat berbagai barang disini.",
	},
	{
		"speaker": "rail",
		"highlight": "",
		"text": "Oh, seperti kantung ajaib.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "objective",
		"text": "Yah, anggaplah begitu. Kau bisa melihat barang apa yang akan kau buat di pojok kanan atas.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "book",
		"text": "Lalu tombol Panduan di atas berisi informasi dari bahan, alat dan proses apa saja yang harus digunakan.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "storage",
		"text": "Di pojok kanan bawah, terdapat penyimpanan berisi barang yang telah dibuat. Ambil secukupnya saja ya, jangan mubazir.",
	},
	{
		"speaker": "rail",
		"highlight": "storage",
		"text": "Mau banjir?",
	},
	{
		"speaker": "ilmuan",
		"highlight": "",
		"text": "Mubazir, itu artinya terlalu berlebihan sampai terbuang. Ahk, lanjut-lanjut.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "hand",
		"text": "Di bagian bawah ini adalah tempat diletakkannya semua kartu yang tadi kau ambil.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "hand",
		"text": "Coba pilih beberapa kartu (Kawat Baja, Mengasah, dan Alat Amplas).",
	},
]

const PREVIEW_EXPLAIN_LINE := {
	"speaker": "ilmuan",
	"highlight": "preview",
	"text": "Nah, lihat pada kotak kecil preview di sebelah kiri, hasil kombinasi tadi akan muncul di gambar tersebut. Sekarang coba tekan 'gabungkan'.",
}

const AFTER_FIRST_CRAFT_LINES: Array[Dictionary] = [
	{
		"speaker": "ilmuan",
		"highlight": "storage",
		"text": "Nah, ini adalah benda pertama yang berhasil kita buat.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "objective",
		"text": "Sekarang coba buat lagi benda lain yang kita butuhkan. Lihat apa yang harus kau buat lagi pada kotak objektif.",
	},
]

const READY_FOR_BAJU_LINES: Array[Dictionary] = [
	{
		"speaker": "ilmuan",
		"highlight": "storage",
		"text": "Baiklah, kita sudah punya ketiga benda utama untuk membuat baju. Ambil ketiga benda yang tadi kita buat di penyimpanan.",
	},
	{
		"speaker": "ilmuan",
		"highlight": "slots",
		"text": "Nah sekarang lakukan hal yang sama. Gabungkan ketiga barang tersebut!",
	},
]

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
	preload("res://data/cards/palu.tres"),
	preload("res://data/cards/menempa.tres"),
	preload("res://data/cards/menumbuk.tres"),
	preload("res://data/cards/mortar.tres"),
	preload("res://data/cards/mawar.tres"),
	preload("res://data/cards/beeswax.tres"),
	preload("res://data/cards/cetakan_lipstik.tres"),
	preload("res://data/cards/lilin.tres"),
	preload("res://data/cards/pewarna.tres"),
	preload("res://data/cards/lipstik_batangan.tres"),
	preload("res://data/cards/lipstik.tres"),
]

const DEFAULT_RECIPES: Array[RecipeData] = [
	preload("res://data/recipes/alat_jahit_recipe.tres"),
	preload("res://data/recipes/kain_recipe.tres"),
	preload("res://data/recipes/gunting_recipe.tres"),
	preload("res://data/recipes/baju_recipe.tres"),
	preload("res://data/recipes/perak_batangan_recipe.tres"),
	preload("res://data/recipes/kaca_recipe.tres"),
	preload("res://data/recipes/cermin_recipe.tres"),
	preload("res://data/recipes/cetakan_lipstik_recipe.tres"),
	preload("res://data/recipes/pewarna_recipe.tres"),
	preload("res://data/recipes/lilin_recipe.tres"),
	preload("res://data/recipes/lipstik_recipe.tres"),
]

const OBJECTIVE_SEQUENCE: Array[StringName] = [
	&"alat_jahit",
	&"kain",
	&"gunting",
	&"baju",
]

const STAGE2_OBJECTIVE_SEQUENCE: Array[StringName] = [
	&"perak_batangan",
	&"kaca",
	&"cermin",
]

const STAGE3_OBJECTIVE_SEQUENCE: Array[StringName] = [
	&"cetakan_lipstik",
	&"pewarna",
	&"lilin",
	&"lipstik",
]

const STORAGE_OUTPUT_IDS: Array[StringName] = [
	&"alat_jahit",
	&"kain",
	&"gunting",
	&"baju",
	&"perak_batangan",
	&"kaca",
	&"cermin",
	&"cetakan_lipstik",
	&"pewarna",
	&"lilin",
	&"lipstik",
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

const STAGE2_DECK_POOLS: Dictionary = {
	&"perak_batangan": [
		&"biji_perak",
		&"peleburan",
		&"tungku",
		&"pasir_silica",
		&"menempa",
		&"palu",
		&"cetakan",
	],
	&"kaca": [
		&"pasir_silica",
		&"peleburan",
		&"tungku",
		&"biji_perak",
		&"menempa",
		&"palu",
		&"cetakan",
	],
	&"cermin": [
		&"cetakan",
		&"peleburan",
		&"tungku",
		&"menempa",
		&"palu",
		&"biji_perak",
		&"pasir_silica",
	],
}

const STAGE3_DECK_POOLS: Dictionary = {
	&"cetakan_lipstik": [
		&"besi_batangan",
		&"peleburan",
		&"tungku",
		&"mawar",
		&"menumbuk",
		&"mortar",
		&"beeswax",
	],
	&"pewarna": [
		&"mawar",
		&"menumbuk",
		&"mortar",
		&"beeswax",
		&"peleburan",
		&"tungku",
		&"besi_batangan",
	],
	&"lilin": [
		&"beeswax",
		&"peleburan",
		&"tungku",
		&"mawar",
		&"menumbuk",
		&"mortar",
		&"besi_batangan",
	],
	&"lipstik": [
		&"besi_batangan",
		&"mawar",
		&"beeswax",
		&"peleburan",
		&"menumbuk",
		&"tungku",
		&"mortar",
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
@onready var combine_slots_row: HBoxContainer = %CombineSlotsRow
@onready var combine_slot_0: Button = %CombineSlot0
@onready var combine_slot_1: Button = %CombineSlot1
@onready var combine_slot_2: Button = %CombineSlot2
@onready var tutorial_avatar_texture: TextureRect = %TutorialAvatarTexture
@onready var tutorial_pill_panel: PanelContainer = %TutorialPillPanel
@onready var tutorial_text_label: Label = %TutorialTextLabel
@onready var tutorial_prompt_label: Label = %TutorialPromptLabel
@onready var combine_button: Button = %CombineButton
@onready var reset_selection_button: Button = %ResetSelectionButton
@onready var card_hand: CardHand = %CardHand
@onready var objective_panel: PanelContainer = %ObjectivePanel
@onready var objective_item_texture: TextureRect = %ObjectiveItemTexture
@onready var objective_target_label: Label = %ObjectiveTargetLabel
@onready var storage_section: VBoxContainer = %StorageSection
@onready var inventory_hint_label: Label = %InventoryHintLabel
@onready var inventory_items_flow: HFlowContainer = %InventoryItemsFlow
@onready var tutorial_dim_overlay: ColorRect = %TutorialDimOverlay
@onready var tutorial_spotlight_ring: Panel = %TutorialSpotlightRing
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
@onready var level_complete_popup: Control = %LevelCompletePopup
@onready var reward_card_pivot: Control = %RewardCardPivot
@onready var reward_card_texture: TextureRect = %RewardCardTexture
@onready var level_continue_button: Button = %LevelContinueButton

var _processor := CraftingProcessor.new()
var _stage_number: int = 1
var _current_objective_index: int = 0
var _deck_injected_items: Array[StringName] = []
var _current_hand_ids: Array[StringName] = []
var _combine_slots: Array[Button] = []
var _tutorial_phase: TutorialPhase = TutorialPhase.INTRO_DIALOGUE
var _tutorial_line_index: int = 0
var _active_highlight_key: String = ""
var _ilmuan_avatar_tex: AtlasTexture
var _rail_avatar_tex: AtlasTexture
var _reward_tween: Tween = null
var _last_preview_matched_id: StringName = &""
var _last_tutorial_speaker: String = ""
var _last_tutorial_text: String = ""
var _pre_mute_volume: float = 0.8


func _ready() -> void:
	if card_catalog.is_empty():
		card_catalog = DEFAULT_CARDS.duplicate()
	if recipes.is_empty():
		recipes = DEFAULT_RECIPES.duplicate()

	_build_avatar_textures()

	_combine_slots = [combine_slot_0, combine_slot_1, combine_slot_2]
	for i in range(_combine_slots.size()):
		var slot_btn := _combine_slots[i]
		slot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var slot_idx := i
		slot_btn.pressed.connect(func() -> void: _on_combine_slot_pressed(slot_idx))

	inventory_manager.register_cards(card_catalog)

	card_hand.max_selected = 3
	card_hand.selection_changed.connect(_on_hand_selection_changed)
	card_hand.selection_limit_reached.connect(_on_hand_selection_limit_reached)
	card_hand.refresh_requested.connect(_on_card_hand_refresh_requested)
	combine_button.pressed.connect(_on_combine_pressed)
	reset_selection_button.pressed.connect(_on_reset_selection_pressed)
	settings_button.pressed.connect(open_settings_popup)
	book_button.pressed.connect(open_book_popup)
	tutorial_pill_panel.gui_input.connect(_on_tutorial_advance_gui_input)
	tutorial_dim_overlay.gui_input.connect(_on_tutorial_advance_gui_input)
	tutorial_spotlight_ring.gui_input.connect(_on_tutorial_advance_gui_input)
	resized.connect(_refresh_spotlight_ring_deferred)

	mute_check_button.toggled.connect(_on_mute_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_book_button.pressed.connect(_on_settings_book_pressed)
	back_to_dialogue_button.pressed.connect(_on_back_to_dialogue_pressed)
	close_settings_button.pressed.connect(close_settings_popup)
	close_book_button.pressed.connect(close_book_popup)
	level_continue_button.pressed.connect(_on_level_continue_pressed)

	_sync_audio_controls_from_server()
	_configure_stage_inventory_and_state()
	AudioManager.play_bgm(&"crafting")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _is_tutorial_click_phase() and not _any_popup_open():
		advance_tutorial_dialogue()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if level_complete_popup.visible:
			return
		if book_popup.visible:
			close_book_popup()
			get_viewport().set_input_as_handled()
		elif settings_popup.visible:
			close_settings_popup()
			get_viewport().set_input_as_handled()
		else:
			open_settings_popup()
			get_viewport().set_input_as_handled()


func setup_stage(stage_number: int) -> void:
	_stage_number = stage_number
	_current_objective_index = 0
	_deck_injected_items.clear()
	_last_preview_matched_id = &""
	if not is_node_ready():
		return
	_configure_stage_inventory_and_state()


func _configure_stage_inventory_and_state() -> void:
	if _stage_number == 3:
		inventory_manager.setup_initial_inventory(
			{
				&"besi_batangan": 3,
				&"mawar": 3,
				&"beeswax": 3,
			},
			[&"peleburan", &"menumbuk"],
			[&"tungku", &"mortar"]
		)
		_tutorial_phase = TutorialPhase.COMPLETED
		_tutorial_line_index = 0
	elif _stage_number == 2:
		inventory_manager.setup_initial_inventory(
			{
				&"biji_perak": 3,
				&"pasir_silica": 3,
			},
			[&"peleburan", &"menempa", &"menumbuk"],
			[&"tungku", &"cetakan", &"palu"]
		)
		_tutorial_phase = TutorialPhase.COMPLETED
		_tutorial_line_index = 0
	else:
		inventory_manager.setup_initial_inventory(
			{
				&"kawat_baja": 3,
				&"benang": 3,
				&"besi_batangan": 3,
			},
			[&"amplas", &"tenun", &"peleburan"],
			[&"batu_asah", &"alat_tenun", &"cetakan"]
		)
		_tutorial_phase = TutorialPhase.INTRO_DIALOGUE
		_tutorial_line_index = 0

	_refresh_objective_and_book()
	_refresh_inventory_panel()
	_refresh_hand(false)
	_update_combine_stage([])
	_apply_tutorial_state()


func _get_active_objective_sequence() -> Array[StringName]:
	if _stage_number == 3:
		return STAGE3_OBJECTIVE_SEQUENCE
	if _stage_number == 2:
		return STAGE2_OBJECTIVE_SEQUENCE
	return OBJECTIVE_SEQUENCE


func _get_active_deck_pools() -> Dictionary:
	if _stage_number == 3:
		return STAGE3_DECK_POOLS
	if _stage_number == 2:
		return STAGE2_DECK_POOLS
	return OBJECTIVE_DECK_POOLS


func get_current_objective_id() -> StringName:
	var seq := _get_active_objective_sequence()
	if _current_objective_index < 0 or _current_objective_index >= seq.size():
		return seq[seq.size() - 1]
	return seq[_current_objective_index]


func get_tutorial_phase() -> TutorialPhase:
	return _tutorial_phase


func get_tutorial_line_index() -> int:
	return _tutorial_line_index


func advance_tutorial_dialogue() -> void:
	match _tutorial_phase:
		TutorialPhase.INTRO_DIALOGUE:
			if _tutorial_line_index < INTRO_TUTORIAL_LINES.size() - 1:
				_tutorial_line_index += 1
				_apply_tutorial_state()
			else:
				_tutorial_phase = TutorialPhase.WAIT_SELECT_CARDS
				_tutorial_line_index = 0
				_apply_tutorial_state()
				if card_hand.get_selected_count() >= 3:
					_tutorial_phase = TutorialPhase.PREVIEW_EXPLAIN_DIALOGUE
					_apply_tutorial_state()
		TutorialPhase.PREVIEW_EXPLAIN_DIALOGUE:
			_tutorial_phase = TutorialPhase.WAIT_PRESS_COMBINE
			_apply_tutorial_state()
		TutorialPhase.AFTER_FIRST_CRAFT_DIALOGUE:
			if _tutorial_line_index < AFTER_FIRST_CRAFT_LINES.size() - 1:
				_tutorial_line_index += 1
				_apply_tutorial_state()
			else:
				_tutorial_phase = TutorialPhase.WAIT_ALL_INTERMEDIATES
				_tutorial_line_index = 0
				_apply_tutorial_state()
				_check_all_intermediates_ready()
		TutorialPhase.READY_FOR_BAJU_DIALOGUE:
			if _tutorial_line_index < READY_FOR_BAJU_LINES.size() - 1:
				_tutorial_line_index += 1
				_apply_tutorial_state()
			else:
				_tutorial_phase = TutorialPhase.WAIT_CRAFT_BAJU
				_tutorial_line_index = 0
				_apply_tutorial_state()


func send_inventory_item_to_deck(card_id: StringName) -> bool:
	if not inventory_manager.has_material(card_id, 1):
		return false
	if not _deck_injected_items.has(card_id):
		_deck_injected_items.append(card_id)
	var card := inventory_manager.get_card(card_id)
	var card_name := card.display_name if card != null else String(card_id)
	stage_feedback_label.text = "'%s' dimasukkan dari penyimpanan ke deck bawah." % card_name
	AudioManager.play_sfx(&"card_pick", 1.04, 1.10)
	_refresh_inventory_panel()
	_refresh_hand(false)
	return true


func craft_selected_cards() -> ProcessingResult:
	var selected := card_hand.get_selected_cards()
	var result := _processor.execute(selected, recipes, inventory_manager)

	if result.status == ProcessingResult.Status.VALIDATION_ERROR:
		AudioManager.play_sfx(&"ui_click", 0.62, 0.68)
		stage_feedback_label.text = result.reason
		_apply_preview_visual("!", "Belum Cocok", null, Color("#1E1610"))
		craft_completed.emit(result)
		return result

	var out_id: StringName = result.output_ids[0] if not result.output_ids.is_empty() else &""
	var out_card := inventory_manager.get_card(out_id)
	var out_name := out_card.display_name if out_card != null else String(out_id)
	var out_icon: Texture2D = out_card.icon if out_card != null else null

	# Keep starter raw materials replenished so experimentation never soft-locks the tutorial.
	var starter_materials: Array[StringName] = [&"kawat_baja", &"benang", &"besi_batangan"]
	if _stage_number == 3:
		starter_materials = [&"besi_batangan", &"mawar", &"beeswax"]
	elif _stage_number == 2:
		starter_materials = [&"biji_perak", &"pasir_silica"]
	for base_id in starter_materials:
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
	if out_id == &"baju" or out_id == &"cermin" or out_id == &"lipstik":
		AudioManager.play_sfx(&"craft_final")
		AudioManager.play_sfx(&"fanfare")
	else:
		_play_intermediate_craft_sfx(out_id)
	_handle_tutorial_after_craft(out_id, out_card)
	craft_completed.emit(result)
	return result


func show_level_complete_popup(card: CardData = null) -> void:
	book_popup.visible = false
	settings_popup.visible = false
	_update_tutorial_overlay_and_spotlight("", false)
	var fallback_tex: Texture2D = BAJU_CARD_TEX
	if _stage_number == 3:
		fallback_tex = LIPSTIK_CARD_TEX
	elif _stage_number == 2:
		fallback_tex = CERMIN_CARD_TEX
	reward_card_texture.texture = card.card_texture if card != null and card.card_texture != null else fallback_tex
	var subtitle_label := level_complete_popup.get_node_or_null("CenterContainer/LevelModalPanel/MarginContainer/LevelVBox/LevelSubtitleLabel") as Label
	var quote_label := get_node_or_null("%LevelCompleteQuoteLabel") as Label
	if _stage_number == 3:
		if subtitle_label != null:
			subtitle_label.text = "Lipstik Berhasil Dibuat!"
		if quote_label != null:
			quote_label.text = "Tadaa! Lipstiknya sudah jadi! Ayo kita lihat reaksi Rail saat mencobanya."
	elif _stage_number == 2:
		if subtitle_label != null:
			subtitle_label.text = "Cermin Berhasil Dibuat!"
		if quote_label != null:
			quote_label.text = "Tadaa! Cermin sudah jadi! Sekarang Rail bisa melihat bayangannya sendiri."
	else:
		if subtitle_label != null:
			subtitle_label.text = "Baju Pertama Berhasil Dibuat!"
		if quote_label != null:
			quote_label.text = "Tadaa! Ini dia baju pertama yang berhasil kita buat, uhh aku tak yakin apakah kalian bisa mengenakannya."
	level_complete_popup.visible = true

	var pivot_size := reward_card_pivot.custom_minimum_size
	reward_card_pivot.pivot_offset = pivot_size * 0.5
	reward_card_pivot.scale = Vector2(0.15, 0.15)
	reward_card_pivot.rotation_degrees = -360.0

	if _reward_tween != null and _reward_tween.is_running():
		_reward_tween.kill()

	_reward_tween = create_tween()
	_reward_tween.set_parallel(true)
	_reward_tween.tween_property(reward_card_pivot, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reward_tween.tween_property(reward_card_pivot, "rotation_degrees", 0.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	level_continue_button.grab_focus()


func open_settings_popup() -> void:
	AudioManager.play_sfx(&"ui_click")
	book_popup.visible = false
	_sync_audio_controls_from_server()
	settings_popup.visible = true
	close_settings_button.grab_focus()


func close_settings_popup() -> void:
	AudioManager.play_sfx(&"ui_click")
	settings_popup.visible = false
	settings_button.grab_focus()


func open_book_popup() -> void:
	AudioManager.play_sfx(&"ui_click")
	settings_popup.visible = false
	_refresh_objective_and_book()
	book_popup.visible = true
	close_book_button.grab_focus()


func close_book_popup() -> void:
	AudioManager.play_sfx(&"ui_click")
	book_popup.visible = false
	book_button.grab_focus()


func _build_avatar_textures() -> void:
	_ilmuan_avatar_tex = AtlasTexture.new()
	_ilmuan_avatar_tex.atlas = PLAYER_SPRITE_TEX
	_ilmuan_avatar_tex.region = Rect2(520, 50, 1060, 1060)

	_rail_avatar_tex = AtlasTexture.new()
	_rail_avatar_tex.atlas = RAIL_SPRITE_TEX
	_rail_avatar_tex.region = Rect2(420, 140, 1100, 1100)


func _any_popup_open() -> bool:
	return settings_popup.visible or book_popup.visible or level_complete_popup.visible


func _is_tutorial_click_phase() -> bool:
	return (
		_tutorial_phase == TutorialPhase.INTRO_DIALOGUE
		or _tutorial_phase == TutorialPhase.PREVIEW_EXPLAIN_DIALOGUE
		or _tutorial_phase == TutorialPhase.AFTER_FIRST_CRAFT_DIALOGUE
		or _tutorial_phase == TutorialPhase.READY_FOR_BAJU_DIALOGUE
	)


func _set_tutorial_bar(speaker: String, text: String, prompt: String) -> void:
	var is_rail := speaker == "rail"
	tutorial_avatar_texture.texture = _rail_avatar_tex if is_rail else _ilmuan_avatar_tex
	# Flip Ilmuan horizontally so he faces right toward the speech pill.
	tutorial_avatar_texture.flip_h = not is_rail
	tutorial_text_label.text = text
	tutorial_prompt_label.text = prompt
	tutorial_prompt_label.visible = not prompt.is_empty()

	var is_dialogue_step := _is_tutorial_click_phase() or _tutorial_phase == TutorialPhase.COMPLETED
	if is_dialogue_step and (speaker != _last_tutorial_speaker or text != _last_tutorial_text):
		AudioManager.play_voice_burst(speaker, 5)
	_last_tutorial_speaker = speaker
	_last_tutorial_text = text


func _play_intermediate_craft_sfx(out_id: StringName) -> void:
	match out_id:
		&"alat_jahit", &"perak_batangan", &"cetakan_lipstik":
			AudioManager.play_sfx(&"craft_step_1")
		&"kain", &"kaca", &"pewarna":
			AudioManager.play_sfx(&"craft_step_2")
		&"gunting", &"lilin":
			AudioManager.play_sfx(&"craft_step_3")
		_:
			AudioManager.play_sfx(&"craft_step_1")


func _get_highlight_target(key: String) -> Control:
	match key:
		"slots":
			return combine_slots_row
		"objective":
			return objective_panel
		"book":
			return book_button
		"storage":
			return storage_section
		"hand":
			return card_hand
		"preview":
			return you_get_frame
	return null


func _update_tutorial_overlay_and_spotlight(highlight_key: String, overlay_active: bool) -> void:
	_active_highlight_key = highlight_key if overlay_active else ""
	for target in [combine_slots_row, objective_panel, book_button, storage_section, card_hand, you_get_frame]:
		if target != null:
			target.z_index = 0

	tutorial_dim_overlay.visible = overlay_active
	if not overlay_active:
		tutorial_spotlight_ring.visible = false
		return

	var focus_target := _get_highlight_target(highlight_key)
	if focus_target == null:
		tutorial_spotlight_ring.visible = false
		return

	focus_target.z_index = 55
	_position_spotlight_ring(focus_target)
	call_deferred("_refresh_spotlight_ring_deferred")


func _position_spotlight_ring(target: Control) -> void:
	if target == null or not tutorial_dim_overlay.visible:
		tutorial_spotlight_ring.visible = false
		return
	var rect := target.get_global_rect().grow(6.0)
	tutorial_spotlight_ring.global_position = rect.position
	tutorial_spotlight_ring.size = rect.size
	tutorial_spotlight_ring.visible = true


func _refresh_spotlight_ring_deferred() -> void:
	if _active_highlight_key.is_empty() or not tutorial_dim_overlay.visible:
		return
	_position_spotlight_ring(_get_highlight_target(_active_highlight_key))


func _apply_tutorial_state() -> void:
	if _stage_number == 3:
		_update_tutorial_overlay_and_spotlight("", false)
		if inventory_manager.has_material(&"lipstik", 1):
			_set_tutorial_bar(
				"ilmuan",
				"Tadaa! Lipstiknya sudah jadi! Ayo kita lihat reaksi Rail saat mencobanya.",
				""
			)
		else:
			_set_tutorial_bar(
				"ilmuan",
				"Perhatikan kotak Objektif dan buka Buku Panduan di atas untuk melihat resep pembuatan Lipstik.",
				""
			)
		return

	if _stage_number == 2:
		_update_tutorial_overlay_and_spotlight("", false)
		if inventory_manager.has_material(&"cermin", 1):
			_set_tutorial_bar(
				"ilmuan",
				"Tadaa! Cermin sudah jadi! Sekarang Rail bisa melihat bayangannya sendiri.",
				""
			)
		else:
			_set_tutorial_bar(
				"ilmuan",
				"Perhatikan kotak Objektif dan buka Buku Panduan di atas untuk melihat resep pembuatan Cermin.",
				""
			)
		return

	match _tutorial_phase:
		TutorialPhase.INTRO_DIALOGUE:
			var entry: Dictionary = INTRO_TUTORIAL_LINES[_tutorial_line_index]
			var is_last := _tutorial_line_index >= INTRO_TUTORIAL_LINES.size() - 1
			var prompt := "[Klik / Spasi]" if not is_last else "[Klik / Spasi untuk Mulai]"
			_set_tutorial_bar(String(entry["speaker"]), String(entry["text"]), prompt)
			_update_tutorial_overlay_and_spotlight(String(entry.get("highlight", "")), true)
		TutorialPhase.WAIT_SELECT_CARDS:
			var last_intro: Dictionary = INTRO_TUTORIAL_LINES[INTRO_TUTORIAL_LINES.size() - 1]
			_set_tutorial_bar(String(last_intro["speaker"]), String(last_intro["text"]), "[Pilih 3 Kartu]")
			_update_tutorial_overlay_and_spotlight("", false)
		TutorialPhase.PREVIEW_EXPLAIN_DIALOGUE:
			_set_tutorial_bar(
				String(PREVIEW_EXPLAIN_LINE["speaker"]),
				String(PREVIEW_EXPLAIN_LINE["text"]),
				"[Klik / Spasi untuk Tekan Gabungkan]"
			)
			_update_tutorial_overlay_and_spotlight(String(PREVIEW_EXPLAIN_LINE["highlight"]), true)
		TutorialPhase.WAIT_PRESS_COMBINE:
			_set_tutorial_bar(
				String(PREVIEW_EXPLAIN_LINE["speaker"]),
				String(PREVIEW_EXPLAIN_LINE["text"]),
				"[Tekan gabungkan]"
			)
			_update_tutorial_overlay_and_spotlight("", false)
		TutorialPhase.AFTER_FIRST_CRAFT_DIALOGUE:
			var entry: Dictionary = AFTER_FIRST_CRAFT_LINES[_tutorial_line_index]
			var is_last := _tutorial_line_index >= AFTER_FIRST_CRAFT_LINES.size() - 1
			var prompt := "[Klik / Spasi]" if not is_last else "[Klik / Spasi untuk Lanjut]"
			_set_tutorial_bar(String(entry["speaker"]), String(entry["text"]), prompt)
			_update_tutorial_overlay_and_spotlight(String(entry.get("highlight", "")), true)
		TutorialPhase.WAIT_ALL_INTERMEDIATES:
			_set_tutorial_bar(
				"ilmuan",
				"Sekarang coba buat lagi benda lain yang kita butuhkan. Lihat apa yang harus kau buat lagi pada kotak objektif.",
				"[Buat Kain & Gunting]"
			)
			_update_tutorial_overlay_and_spotlight("", false)
		TutorialPhase.READY_FOR_BAJU_DIALOGUE:
			var entry: Dictionary = READY_FOR_BAJU_LINES[_tutorial_line_index]
			var is_last := _tutorial_line_index >= READY_FOR_BAJU_LINES.size() - 1
			var prompt := "[Klik / Spasi]" if not is_last else "[Klik / Spasi untuk Lanjut]"
			_set_tutorial_bar(String(entry["speaker"]), String(entry["text"]), prompt)
			_update_tutorial_overlay_and_spotlight(String(entry.get("highlight", "")), true)
		TutorialPhase.WAIT_CRAFT_BAJU:
			var last_ready: Dictionary = READY_FOR_BAJU_LINES[READY_FOR_BAJU_LINES.size() - 1]
			_set_tutorial_bar(String(last_ready["speaker"]), String(last_ready["text"]), "[Gabungkan 3 Bahan]")
			_update_tutorial_overlay_and_spotlight("", false)
		TutorialPhase.COMPLETED:
			_set_tutorial_bar(
				"ilmuan",
				"Tadaa! Ini dia baju pertama yang berhasil kita buat, uhh aku tak yakin apakah kalian bisa mengenakannya.",
				""
			)
			_update_tutorial_overlay_and_spotlight("", false)


func _handle_tutorial_after_craft(out_id: StringName, out_card: CardData) -> void:
	if _stage_number == 3:
		if out_id == &"lipstik":
			_set_tutorial_bar(
				"ilmuan",
				"Tadaa! Lipstiknya sudah jadi! Ayo kita lihat reaksi Rail saat mencobanya.",
				""
			)
			show_level_complete_popup(out_card)
		elif (
			inventory_manager.has_material(&"cetakan_lipstik", 1)
			and inventory_manager.has_material(&"pewarna", 1)
			and inventory_manager.has_material(&"lilin", 1)
		):
			_set_tutorial_bar(
				"ilmuan",
				"Cetakan, Pewarna, dan Lilin sudah siap! Ambil ketiganya dari Penyimpanan lalu gabungkan menjadi Lipstik.",
				""
			)
		return

	if _stage_number == 2:
		if out_id == &"cermin":
			_set_tutorial_bar(
				"ilmuan",
				"Tadaa! Cermin sudah jadi! Sekarang Rail bisa melihat bayangannya sendiri.",
				""
			)
			show_level_complete_popup(out_card)
		elif inventory_manager.has_material(&"perak_batangan", 1) and inventory_manager.has_material(&"kaca", 1):
			_set_tutorial_bar(
				"ilmuan",
				"Perak Batangan dan Kaca sudah siap! Ambil keduanya dari Penyimpanan lalu gabungkan dengan Cetakan.",
				""
			)
		return

	if out_id == &"baju":
		_tutorial_phase = TutorialPhase.COMPLETED
		_tutorial_line_index = 0
		_apply_tutorial_state()
		show_level_complete_popup(out_card)
		return

	if _has_all_baju_ingredients():
		_tutorial_phase = TutorialPhase.READY_FOR_BAJU_DIALOGUE
		_tutorial_line_index = 0
		_apply_tutorial_state()
		return

	if _tutorial_phase in [
		TutorialPhase.INTRO_DIALOGUE,
		TutorialPhase.WAIT_SELECT_CARDS,
		TutorialPhase.PREVIEW_EXPLAIN_DIALOGUE,
		TutorialPhase.WAIT_PRESS_COMBINE,
	]:
		_tutorial_phase = TutorialPhase.AFTER_FIRST_CRAFT_DIALOGUE
		_tutorial_line_index = 0
		_apply_tutorial_state()


func _has_all_baju_ingredients() -> bool:
	return (
		inventory_manager.has_material(&"alat_jahit", 1)
		and inventory_manager.has_material(&"kain", 1)
		and inventory_manager.has_material(&"gunting", 1)
	)


func _check_all_intermediates_ready() -> void:
	if _has_all_baju_ingredients() and _tutorial_phase == TutorialPhase.WAIT_ALL_INTERMEDIATES:
		_tutorial_phase = TutorialPhase.READY_FOR_BAJU_DIALOGUE
		_tutorial_line_index = 0
		_apply_tutorial_state()


func _advance_objective_if_matched(crafted_output_id: StringName) -> void:
	var seq := _get_active_objective_sequence()
	if crafted_output_id == get_current_objective_id():
		if _current_objective_index < seq.size() - 1:
			_current_objective_index += 1
		return

	for i in range(seq.size()):
		var obj_id := seq[i]
		if not inventory_manager.has_material(obj_id, 1):
			_current_objective_index = i
			return
	_current_objective_index = seq.size() - 1


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
	var pools := _get_active_deck_pools()
	var default_pool_key: StringName = &"alat_jahit"
	if _stage_number == 3:
		default_pool_key = &"cetakan_lipstik"
	elif _stage_number == 2:
		default_pool_key = &"perak_batangan"
	var base_pool: Array = pools.get(current_obj, pools[default_pool_key])
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

	if _stage_number == 3 and inventory_manager.has_material(&"lipstik", 1):
		objective_target_label.text = "Lipstik (Selesai!)"
	elif _stage_number == 2 and inventory_manager.has_material(&"cermin", 1):
		objective_target_label.text = "Cermin (Selesai!)"
	elif _stage_number == 1 and inventory_manager.has_material(&"baju", 1):
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

	if _stage_number == 3:
		left_page_text.text = (
			"Bahan Setengah Jadi:\n\n"
			+ "1. Cetakan\n"
			+ "   Besi Batangan + Melebur + Tungku\n\n"
			+ "2. Pewarna\n"
			+ "   Mawar + Menumbuk + Mortar\n\n"
			+ "3. Lilin\n"
			+ "   Beeswax + Melebur + Tungku"
		)

		var has_ct := "v" if inventory_manager.has_material(&"cetakan_lipstik", 1) else " "
		var has_pw := "v" if inventory_manager.has_material(&"pewarna", 1) else " "
		var has_ll := "v" if inventory_manager.has_material(&"lilin", 1) else " "
		right_page_text.text = (
			"Aturan Bahan Jadi:\n\n"
			+ "LIPSTIK =\n"
			+ "[%s] Cetakan\n"
			+ "[%s] Pewarna\n"
			+ "[%s] Lilin\n\n"
			+ "Alur:\n"
			+ "Hasil gabungkan masuk ke Penyimpanan. Klik kartu mini di Penyimpanan agar masuk ke Deck Bawah."
		) % [has_ct, has_pw, has_ll]
		return

	if _stage_number == 2:
		left_page_text.text = (
			"Bahan Setengah Jadi:\n\n"
			+ "1. Perak Batangan\n"
			+ "   Biji Perak + Melebur + Tungku\n\n"
			+ "2. Kaca\n"
			+ "   Pasir Silica + Melebur + Tungku"
		)

		var has_pb := "v" if inventory_manager.has_material(&"perak_batangan", 1) else " "
		var has_kc := "v" if inventory_manager.has_material(&"kaca", 1) else " "
		right_page_text.text = (
			"Aturan Bahan Jadi:\n\n"
			+ "CERMIN =\n"
			+ "[%s] Perak Batangan\n"
			+ "[%s] Kaca\n"
			+ "[v] Cetakan (Alat)\n\n"
			+ "Alur:\n"
			+ "Hasil gabungkan masuk ke Penyimpanan. Klik kartu mini di Penyimpanan agar masuk ke Deck Bawah."
		) % [has_pb, has_kc]
		return

	left_page_text.text = (
		"Bahan Setengah Jadi:\n\n"
		+ "1. Alat Jahit\n"
		+ "   Kawat Baja + Mengasah + Alat Amplas\n\n"
		+ "2. Kain\n"
		+ "   Benang + Menenun + Alat Tenun\n\n"
		+ "3. Gunting\n"
		+ "   Besi Batangan + Melebur + Cetakan"
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
		+ "Hasil gabungkan masuk ke Penyimpanan. Klik kartu mini di Penyimpanan agar masuk ke Deck Bawah."
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
	btn.custom_minimum_size = Vector2(96, 136)
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
		var slot_card_view := slot_btn.get_node_or_null("SlotCardView") as CardUI

		if i < selected_cards.size() and selected_cards[i] != null:
			var card := selected_cards[i]
			slot_btn.disabled = false
			slot_btn.tooltip_text = "%s - Klik untuk melepas kartu" % card.display_name
			if slot_card_view != null:
				slot_card_view.visible = true
				slot_card_view.set_static_display(card, -1)
		else:
			slot_btn.disabled = true
			slot_btn.tooltip_text = "Slot %d kosong" % (i + 1)
			if slot_card_view != null:
				slot_card_view.visible = false

	combine_button.disabled = selected_cards.is_empty()
	reset_selection_button.disabled = selected_cards.is_empty()

	if selected_cards.is_empty():
		_last_preview_matched_id = &""
		_apply_preview_visual("?", "Pilih Kartu", null, Color("#1E1610"))
		return

	var preview_result := _processor.validate_selection(selected_cards, recipes, inventory_manager)
	if preview_result.status == ProcessingResult.Status.SUCCESS and not preview_result.output_ids.is_empty():
		var matched_id := preview_result.output_ids[0]
		var out_card := inventory_manager.get_card(matched_id)
		var out_name := out_card.display_name if out_card != null else String(matched_id)
		var out_icon: Texture2D = out_card.icon if out_card != null else null
		_apply_preview_visual("*", out_name, out_icon, Color("#1E1610"))
		stage_feedback_label.text = "Kombinasi cocok! Tekan 'gabungkan' untuk membuat '%s'." % out_name
		if matched_id != _last_preview_matched_id:
			_last_preview_matched_id = matched_id
			AudioManager.play_sfx(&"preview_match")
	elif selected_cards.size() < 3:
		_last_preview_matched_id = &""
		_apply_preview_visual("...", "%d / 3 Kartu" % selected_cards.size(), null, Color("#1E1610"))
		stage_feedback_label.text = "Pilih %d kartu lagi dari deck bawah." % (3 - selected_cards.size())
	else:
		_last_preview_matched_id = &""
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
	var linear := GameSettings.music_volume
	if linear > 0.001:
		_pre_mute_volume = linear
	mute_check_button.set_pressed_no_signal(is_muted or linear <= 0.001)
	volume_slider.set_value_no_signal(linear)
	volume_value_label.text = "%d%%" % roundi(linear * 100.0)


func _on_mute_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx(&"ui_click")
	if toggled_on:
		if volume_slider.value > 0.001:
			_pre_mute_volume = volume_slider.value
		GameSettings.set_music_volume(0.0)
		volume_slider.set_value_no_signal(0.0)
		volume_value_label.text = "0%"
	else:
		var restore := volume_slider.value if volume_slider.value > 0.001 else _pre_mute_volume
		GameSettings.set_music_volume(restore)
		volume_slider.set_value_no_signal(restore)
		volume_value_label.text = "%d%%" % roundi(restore * 100.0)
	GameSettings.save_settings()


func _on_volume_changed(value: float) -> void:
	var clamped := clampf(value, 0.0, 1.0)
	if clamped > 0.001:
		_pre_mute_volume = clamped
	GameSettings.set_music_volume(clamped)
	GameSettings.save_settings()
	mute_check_button.set_pressed_no_signal(clamped <= 0.001)
	volume_value_label.text = "%d%%" % roundi(clamped * 100.0)


func _on_tutorial_advance_gui_input(event: InputEvent) -> void:
	if not _is_tutorial_click_phase():
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			advance_tutorial_dialogue()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		advance_tutorial_dialogue()
		get_viewport().set_input_as_handled()


func _on_card_hand_refresh_requested() -> void:
	_refresh_hand(true)
	stage_feedback_label.text = "Kartu di deck bawah diacak ulang dari pool yang tersedia."


func _on_hand_selection_changed(selected_cards: Array[CardData], _max_selected: int) -> void:
	_update_combine_stage(selected_cards)
	if selected_cards.size() >= 3 and _tutorial_phase == TutorialPhase.WAIT_SELECT_CARDS:
		_tutorial_phase = TutorialPhase.PREVIEW_EXPLAIN_DIALOGUE
		_tutorial_line_index = 0
		_apply_tutorial_state()


func _on_hand_selection_limit_reached(max_sel: int) -> void:
	stage_feedback_label.text = "Area gabungkan tengah maksimal menampung %d kartu. Klik kartu tengah atau tekan reset." % max_sel


func _on_combine_slot_pressed(slot_index: int) -> void:
	AudioManager.play_sfx(&"card_pick", 0.86, 0.92)
	card_hand.deselect_card_by_index(slot_index)


func _on_combine_pressed() -> void:
	craft_selected_cards()


func _on_reset_selection_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	card_hand.clear_selection()
	stage_feedback_label.text = "Pilihan kartu di area tengah direset."


func _on_settings_book_pressed() -> void:
	open_book_popup()


func _on_back_to_dialogue_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	dialogue_requested.emit()


func _on_level_continue_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	level_complete_popup.visible = false
	dialogue_requested.emit()
