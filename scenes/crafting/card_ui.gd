class_name CardUI
extends Control

signal card_clicked(card_ui: CardUI)
signal hover_changed(card_ui: CardUI, hovered: bool)

const LIFT_OFFSET_SELECTED := -14.0
const LIFT_OFFSET_HOVER := -10.0
const SCALE_IDLE := Vector2.ONE
const SCALE_HOVER := Vector2(1.07, 1.07)
const SCALE_SELECTED := Vector2(1.04, 1.04)
const ANIM_SPEED := 14.0

const BLANK_MATERIAL_TEX: Texture2D = preload("res://assets/card/Group 32.png")
const BLANK_TOOL_TEX: Texture2D = preload("res://assets/card/Group 34.png")
const BLANK_ACTION_TEX: Texture2D = preload("res://assets/card/Group 36.png")

@onready var visual_card: Control = %VisualCard
@onready var card_art_texture: TextureRect = %CardArtTexture
@onready var dynamic_overlay: MarginContainer = %DynamicOverlay
@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var stock_pill: PanelContainer = %StockPill
@onready var stock_badge: Label = %StockBadge
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
	custom_minimum_size = Vector2(114, 160)
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


# Reuse the exact same card artwork and blank-frame fallback inside combine slots and storage mini-cards.
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

	if card_data.card_texture != null:
		card_art_texture.texture = card_data.card_texture
		dynamic_overlay.visible = false
	else:
		card_art_texture.texture = _get_blank_frame_texture(card_data.category)
		dynamic_overlay.visible = true
		_style_dynamic_overlay(card_data)

	if card_data.category == CardData.Category.MATERIAL and _stock_count >= 0:
		stock_pill.visible = true
		stock_badge.text = "x%d" % _stock_count
	else:
		stock_pill.visible = false

	disabled_scrim.visible = _is_disabled
	if _is_disabled:
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		card_art_texture.modulate = Color(0.75, 0.75, 0.75, 1.0)
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card_art_texture.modulate = Color.WHITE

	_update_z_index()
	_update_highlight_border()

	if not animate and not _static_display:
		visual_card.pivot_offset = custom_minimum_size * 0.5
		visual_card.position.y = _fan_offset_y + (LIFT_OFFSET_SELECTED if _is_selected else 0.0)
		visual_card.rotation_degrees = 0.0 if _is_selected else _fan_angle_deg
		visual_card.scale = SCALE_SELECTED if _is_selected else SCALE_IDLE


func _style_dynamic_overlay(data: CardData) -> void:
	var is_yellow := data.category == CardData.Category.PROCESS
	var text_col := Color("#1E190A") if is_yellow else Color("#FFFDF7")
	var outline_col := Color("#FFE680") if is_yellow else Color("#1A120B")

	name_label.text = data.display_name
	name_label.add_theme_color_override("font_color", text_col)
	name_label.add_theme_color_override("font_outline_color", outline_col)
	name_label.add_theme_constant_override("outline_size", 2 if is_yellow else 3)

	if _is_mini_display or (size.x > 0.0 and size.x < 100.0):
		dynamic_overlay.add_theme_constant_override("margin_left", 16)
		dynamic_overlay.add_theme_constant_override("margin_right", 16)
		name_label.add_theme_font_size_override("font_size", 11)
		icon_texture.custom_minimum_size = Vector2(26, 26)
	else:
		dynamic_overlay.add_theme_constant_override("margin_left", 20)
		dynamic_overlay.add_theme_constant_override("margin_right", 20)
		name_label.add_theme_font_size_override("font_size", 14)
		icon_texture.custom_minimum_size = Vector2(44, 44)

	if data.icon != null:
		icon_texture.texture = data.icon
		icon_texture.visible = true
	else:
		icon_texture.texture = null
		icon_texture.visible = false


func _get_blank_frame_texture(category: CardData.Category) -> Texture2D:
	match category:
		CardData.Category.MATERIAL:
			return BLANK_MATERIAL_TEX
		CardData.Category.PROCESS:
			return BLANK_ACTION_TEX
		CardData.Category.TOOL:
			return BLANK_TOOL_TEX
	return BLANK_MATERIAL_TEX


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
