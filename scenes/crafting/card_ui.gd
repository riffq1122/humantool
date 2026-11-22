class_name CardUI
extends Control

signal card_clicked(card_ui: CardUI)
signal hover_changed(card_ui: CardUI, hovered: bool)

const LIFT_OFFSET_SELECTED := -14.0
const LIFT_OFFSET_HOVER := -10.0
const SCALE_IDLE := Vector2.ONE
const SCALE_HOVER := Vector2(1.06, 1.06)
const SCALE_SELECTED := Vector2(1.03, 1.03)
const ANIM_SPEED := 14.0

const COLOR_MATERIAL_BG := Color("#9A4E24")
const COLOR_PROCESS_BG := Color("#E5B218")
const COLOR_TOOL_BG := Color("#5E7083")
const COLOR_FINAL_BG := Color("#67549C")
const FINAL_ITEM_IDS: Array[StringName] = [&"baju", &"cermin", &"lipstik"]

@onready var visual_card: Control = %VisualCard
@onready var card_outer_frame: PanelContainer = %CardOuterFrame
@onready var content_margin: MarginContainer = %ContentMargin
@onready var category_tag_label: Label = %CategoryTagLabel
@onready var stock_pill: PanelContainer = %StockPill
@onready var stock_badge: Label = %StockBadge
@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var selection_highlight: Panel = %SelectionHighlight
@onready var disabled_scrim: Panel = %DisabledScrim

var card_data: CardData = null
var _stock_count: int = -1
var _is_selected: bool = false
var _is_hovered: bool = false
var _is_focused: bool = false
var _is_disabled: bool = false
var _static_display: bool = false
var _is_mini_display: bool = false
var _base_z_index: int = 0
var _fan_angle_deg: float = 0.0
var _fan_offset_y: float = 0.0
var _hover_tilt_deg: float = 0.0
var _target_slot_pos: Vector2 = Vector2.ZERO
var _has_slot_pos: bool = false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	_refresh_visuals(false)


func _process(delta: float) -> void:
	if _static_display:
		return

	var weight := 1.0 - exp(-ANIM_SPEED * delta)

	if _has_slot_pos:
		position = position.lerp(_target_slot_pos, weight)

	var lift_y := 0.0
	var target_scale := SCALE_IDLE
	var target_rot := _fan_angle_deg

	if _is_selected:
		lift_y = LIFT_OFFSET_SELECTED
		target_scale = SCALE_HOVER if _is_hovered else SCALE_SELECTED
		target_rot = _hover_tilt_deg if _is_hovered else 0.0
	elif (_is_hovered or _is_focused) and not _is_disabled:
		lift_y = LIFT_OFFSET_HOVER
		target_scale = SCALE_HOVER
		target_rot = _hover_tilt_deg

	visual_card.pivot_offset = visual_card.size * 0.5
	visual_card.position.y = lerpf(visual_card.position.y, _fan_offset_y + lift_y, weight)
	visual_card.scale = visual_card.scale.lerp(target_scale, weight)
	visual_card.rotation_degrees = lerpf(visual_card.rotation_degrees, target_rot, weight)


func setup_card(p_card_data: CardData, p_stock_count: int = -1) -> void:
	_static_display = false
	_is_mini_display = false
	custom_minimum_size = Vector2(122, 172)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	card_data = p_card_data
	_stock_count = p_stock_count
	_is_selected = false
	_is_disabled = (
		p_card_data != null
		and p_card_data.category == CardData.Category.MATERIAL
		and p_stock_count == 0
	)
	if is_node_ready():
		_refresh_visuals(false)


# Reuse the exact same card layout inside combine slots and storage mini-cards.
func set_static_display(p_card_data: CardData, p_stock_count: int = -1, p_mini: bool = false) -> void:
	_static_display = true
	_is_mini_display = p_mini
	custom_minimum_size = Vector2.ZERO
	_has_slot_pos = false
	_is_selected = false
	_is_hovered = false
	_is_focused = false
	_is_disabled = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	card_data = p_card_data
	_stock_count = p_stock_count
	if is_node_ready():
		_refresh_visuals(false)
		visual_card.position = Vector2.ZERO
		visual_card.rotation_degrees = 0.0
		visual_card.scale = Vector2.ONE


func set_hand_pose(
	slot_pos: Vector2,
	angle_degrees: float,
	arc_offset_y: float,
	base_z: int,
	snap: bool = false
) -> void:
	_target_slot_pos = slot_pos
	_has_slot_pos = true
	_fan_angle_deg = angle_degrees
	_fan_offset_y = arc_offset_y
	_base_z_index = base_z
	_update_z_index()

	if snap:
		position = slot_pos
		if is_node_ready():
			visual_card.pivot_offset = custom_minimum_size * 0.5
			visual_card.position.y = _fan_offset_y + (LIFT_OFFSET_SELECTED if _is_selected else 0.0)
			visual_card.rotation_degrees = 0.0 if _is_selected else _fan_angle_deg
			visual_card.scale = SCALE_SELECTED if _is_selected else SCALE_IDLE


func set_selected(selected: bool, animate: bool = true) -> void:
	if _is_disabled and selected:
		return
	_is_selected = selected
	if is_node_ready():
		_refresh_visuals(animate)


func is_selected() -> bool:
	return _is_selected


func is_card_disabled() -> bool:
	return _is_disabled


func _gui_input(event: InputEvent) -> void:
	if _static_display or _is_disabled:
		return

	if event is InputEventMouseMotion and _is_hovered:
		var motion := event as InputEventMouseMotion
		if motion != null and size.x > 0.0:
			var norm_x := clampf((motion.position.x / size.x) * 2.0 - 1.0, -1.0, 1.0)
			_hover_tilt_deg = norm_x * 3.5
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event != null and mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			grab_focus()
			card_clicked.emit(self)
			accept_event()
	elif event.is_action_pressed("ui_accept"):
		card_clicked.emit(self)
		accept_event()


func _refresh_visuals(animate: bool) -> void:
	if card_data == null:
		return

	tooltip_text = card_data.description

	var is_final := FINAL_ITEM_IDS.has(card_data.card_id)
	var is_yellow := card_data.category == CardData.Category.PROCESS and not is_final
	var bg_col := _resolve_card_bg_color(card_data, is_final)

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = bg_col
	frame_style.border_color = Color("#120D09")
	frame_style.set_border_width_all(3)
	frame_style.set_corner_radius_all(13)
	card_outer_frame.add_theme_stylebox_override("panel", frame_style)

	category_tag_label.text = _resolve_category_tag(card_data.category, is_final)
	category_tag_label.add_theme_color_override("font_color", Color("#1A1408") if is_yellow else Color("#FFF8EE"))

	name_label.text = card_data.display_name
	icon_texture.texture = card_data.icon if card_data.icon != null else card_data.card_texture

	if _is_mini_display:
		content_margin.add_theme_constant_override("margin_left", 5)
		content_margin.add_theme_constant_override("margin_right", 5)
		content_margin.add_theme_constant_override("margin_top", 4)
		content_margin.add_theme_constant_override("margin_bottom", 5)
		category_tag_label.add_theme_font_size_override("font_size", 9)
		stock_badge.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_font_size_override("font_size", 13)
	elif _static_display:
		content_margin.add_theme_constant_override("margin_left", 7)
		content_margin.add_theme_constant_override("margin_right", 7)
		content_margin.add_theme_constant_override("margin_top", 6)
		content_margin.add_theme_constant_override("margin_bottom", 7)
		category_tag_label.add_theme_font_size_override("font_size", 12)
		stock_badge.add_theme_font_size_override("font_size", 14)
		name_label.add_theme_font_size_override("font_size", 18)
	else:
		content_margin.add_theme_constant_override("margin_left", 6)
		content_margin.add_theme_constant_override("margin_right", 6)
		content_margin.add_theme_constant_override("margin_top", 5)
		content_margin.add_theme_constant_override("margin_bottom", 6)
		category_tag_label.add_theme_font_size_override("font_size", 11)
		stock_badge.add_theme_font_size_override("font_size", 13)
		name_label.add_theme_font_size_override("font_size", 14)

	if card_data.category == CardData.Category.MATERIAL and _stock_count >= 0:
		stock_pill.visible = true
		stock_badge.text = "x%d" % _stock_count
	else:
		stock_pill.visible = false

	disabled_scrim.visible = _is_disabled
	if _is_disabled:
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		card_outer_frame.modulate = Color(0.75, 0.75, 0.75, 1.0)
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card_outer_frame.modulate = Color.WHITE

	_update_z_index()
	_update_highlight_border()

	if not animate and not _static_display:
		visual_card.pivot_offset = custom_minimum_size * 0.5
		visual_card.position.y = _fan_offset_y + (LIFT_OFFSET_SELECTED if _is_selected else 0.0)
		visual_card.rotation_degrees = 0.0 if _is_selected else _fan_angle_deg
		visual_card.scale = SCALE_SELECTED if _is_selected else SCALE_IDLE


func _resolve_card_bg_color(data: CardData, is_final: bool) -> Color:
	if is_final:
		return COLOR_FINAL_BG
	match data.category:
		CardData.Category.MATERIAL:
			return COLOR_MATERIAL_BG
		CardData.Category.PROCESS:
			return COLOR_PROCESS_BG
		CardData.Category.TOOL:
			return COLOR_TOOL_BG
	return COLOR_MATERIAL_BG


func _resolve_category_tag(category: CardData.Category, is_final: bool) -> String:
	if is_final:
		return "ITEM"
	match category:
		CardData.Category.MATERIAL:
			return "MATERIAL"
		CardData.Category.PROCESS:
			return "ACTION"
		CardData.Category.TOOL:
			return "TOOL"
	return "KARTU"


func _update_z_index() -> void:
	if _static_display:
		z_index = 0
		return
	# Raise z_index instead of move_to_front() so sibling layout order never shifts.
	if _is_hovered:
		z_index = 30
	elif _is_selected:
		z_index = 15 + _base_z_index
	else:
		z_index = _base_z_index


func _update_highlight_border() -> void:
	if _static_display:
		selection_highlight.visible = false
		return

	if _is_selected:
		selection_highlight.visible = true
		_set_highlight_color(Color("#FFE45E"), 4)
	elif _is_focused:
		selection_highlight.visible = true
		_set_highlight_color(Color("#FFF5CC"), 3)
	elif _is_hovered and not _is_disabled:
		selection_highlight.visible = true
		_set_highlight_color(Color(1.0, 0.96, 0.82, 0.85), 2)
	else:
		selection_highlight.visible = false


func _set_highlight_color(col: Color, width: int) -> void:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = col
	style.set_border_width_all(width)
	style.set_corner_radius_all(14)
	selection_highlight.add_theme_stylebox_override("panel", style)


func _on_mouse_entered() -> void:
	if _static_display:
		return
	_is_hovered = true
	_update_z_index()
	_update_highlight_border()
	hover_changed.emit(self, true)


func _on_mouse_exited() -> void:
	if _static_display:
		return
	_is_hovered = false
	_hover_tilt_deg = 0.0
	_update_z_index()
	_update_highlight_border()
	hover_changed.emit(self, false)


func _on_focus_entered() -> void:
	if _static_display:
		return
	_is_focused = true
	_update_z_index()
	_update_highlight_border()


func _on_focus_exited() -> void:
	if _static_display:
		return
	_is_focused = false
	_update_z_index()
	_update_highlight_border()
