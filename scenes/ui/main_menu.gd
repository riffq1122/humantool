extends Control
## Title screen: Mainkan / Pengaturan / Keluar, with an in-place settings panel.

signal play_requested

const FONT_GOCHI := preload("res://assets/fonts/Gochi_Hand/GochiHand-Regular.ttf")
const TEXT_LIGHT := Color("#FFFFFF")
const TEXT_OUTLINE := Color("#3A2414")
const TEXT_DARK := Color("#3A2414")
const HIGHLIGHT := Color("#C8700F")
const HIGHLIGHT_PRESSED := Color("#9A520A")
const TRACK := Color("#6B4524")

@onready var _play_button: Button = %PlayButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _settings_overlay: Control = %SettingsOverlay
@onready var _title: Label = %Title
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _fullscreen_toggle: CheckButton = %FullscreenToggle
@onready var _back_button: Button = %BackButton
@onready var _rail: TextureRect = %Rail
@onready var _ilmuan: TextureRect = %Ilmuan

var _using_keyboard := false
var _last_sfx_preview_msec: int = 0


func _ready() -> void:
	for button: Button in [_play_button, _settings_button, _quit_button, _back_button]:
		_style_menu_button(button)
	_style_title(_title)
	for row_label: Label in [
		$SettingsOverlay/SettingsPanel/Content/MusicRow/MusicLabel,
		$SettingsOverlay/SettingsPanel/Content/SfxRow/SfxLabel,
		$SettingsOverlay/SettingsPanel/Content/FullscreenRow/FullscreenLabel,
	]:
		row_label.add_theme_font_override("font", FONT_GOCHI)
		row_label.add_theme_font_size_override("font_size", 28)
		row_label.add_theme_color_override("font_color", TEXT_DARK)
	_style_slider(_music_slider)
	_style_slider(_sfx_slider)
	_fullscreen_toggle.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_fullscreen_toggle.add_theme_stylebox_override("focus", _make_focus_ring())

	# Quitting does nothing in a browser tab, so the button would be a dead control there.
	_quit_button.visible = not OS.has_feature("web")

	_play_button.pressed.connect(_on_play_pressed)
	_settings_button.pressed.connect(_open_settings)
	_quit_button.pressed.connect(func() -> void: get_tree().quit())
	_back_button.pressed.connect(_close_settings)

	_music_slider.value = GameSettings.music_volume
	_sfx_slider.value = GameSettings.sfx_volume
	_fullscreen_toggle.button_pressed = GameSettings.fullscreen
	_music_slider.value_changed.connect(GameSettings.set_music_volume)
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	_fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)

	AudioManager.play_bgm(&"menu")
	_start_idle_motion()


func _input(event: InputEvent) -> void:
	# Track the last input device so focus highlights only appear for keyboard/gamepad users.
	if event is InputEventKey or event is InputEventJoypadButton:
		_using_keyboard = true
	elif event is InputEventMouseButton:
		_using_keyboard = false


func _unhandled_input(event: InputEvent) -> void:
	if _settings_overlay.visible and event.is_action_pressed("ui_cancel"):
		_close_settings()
		get_viewport().set_input_as_handled()
		return
	# Nothing is focused at start (no highlight until hover); the first arrow key enters the menu.
	if get_viewport().gui_get_focus_owner() == null:
		for action in ["ui_up", "ui_down", "ui_focus_next", "ui_focus_prev"]:
			if event.is_action_pressed(action):
				_play_button.grab_focus()
				get_viewport().set_input_as_handled()
				return


func _on_play_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	# Block double-clicks while the loading screen fades in.
	for button: Button in [_play_button, _settings_button, _quit_button]:
		button.disabled = true
	play_requested.emit()


func _open_settings() -> void:
	AudioManager.play_sfx(&"ui_click")
	_settings_overlay.visible = true
	if _using_keyboard:
		_music_slider.grab_focus()
	else:
		_release_focus()


func _close_settings() -> void:
	AudioManager.play_sfx(&"ui_click")
	_settings_overlay.visible = false
	GameSettings.save_settings()
	if _using_keyboard:
		_settings_button.grab_focus()
	else:
		_release_focus()


func _on_sfx_slider_changed(value: float) -> void:
	GameSettings.set_sfx_volume(value)
	if not _settings_overlay.visible:
		return
	var now := Time.get_ticks_msec()
	if now - _last_sfx_preview_msec >= 120:
		_last_sfx_preview_msec = now
		AudioManager.play_sfx(&"ui_click")


func _on_fullscreen_toggled(enabled: bool) -> void:
	GameSettings.set_fullscreen(enabled)
	if _settings_overlay.visible:
		AudioManager.play_sfx(&"ui_click")


func _release_focus() -> void:
	var owner_control := get_viewport().gui_get_focus_owner()
	if owner_control != null:
		owner_control.release_focus()


func _start_idle_motion() -> void:
	# Small loops so the chase on the title screen reads as a moment, not a still.
	var rail_tween := create_tween().set_loops()
	rail_tween.tween_property(_rail, "rotation", deg_to_rad(2.5), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rail_tween.tween_property(_rail, "rotation", deg_to_rad(-2.5), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var base_y := _ilmuan.position.y
	var ilmuan_tween := create_tween().set_loops()
	ilmuan_tween.tween_property(_ilmuan, "position:y", base_y - 8.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	ilmuan_tween.tween_property(_ilmuan, "position:y", base_y, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _style_menu_button(button: Button) -> void:
	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = 24
	empty.content_margin_right = 24
	var highlight := _make_brush_style(HIGHLIGHT)
	var pressed := _make_brush_style(HIGHLIGHT_PRESSED)

	button.flat = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", highlight)
	button.add_theme_stylebox_override("focus", highlight)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_font_override("font", FONT_GOCHI)
	button.add_theme_font_size_override("font_size", 34)
	button.add_theme_constant_override("outline_size", 8)
	button.add_theme_color_override("font_outline_color", TEXT_OUTLINE)
	for color_name in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(color_name, TEXT_LIGHT)
	button.add_theme_color_override("font_disabled_color", Color(TEXT_LIGHT, 0.6))


func _style_title(label: Label) -> void:
	label.add_theme_font_override("font", FONT_GOCHI)
	label.add_theme_font_size_override("font_size", 42)
	label.add_theme_color_override("font_color", TEXT_LIGHT)
	label.add_theme_constant_override("outline_size", 10)
	label.add_theme_color_override("font_outline_color", TEXT_OUTLINE)


func _style_slider(slider: HSlider) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = TRACK
	track.set_corner_radius_all(5)
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = HIGHLIGHT
	var fill_hover := track.duplicate() as StyleBoxFlat
	fill_hover.bg_color = HIGHLIGHT.lightened(0.15)

	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill_hover)
	slider.add_theme_stylebox_override("focus", _make_focus_ring())


# Orange brush stroke that fades out at both ends, matching the menu mockup.
func _make_brush_style(color: Color) -> StyleBoxTexture:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	gradient.colors = PackedColorArray([Color(color, 0.0), color, color, Color(color, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 8
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.content_margin_left = 24
	style.content_margin_right = 24
	return style


func _make_focus_ring() -> StyleBoxFlat:
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.border_color = TEXT_LIGHT
	ring.set_border_width_all(2)
	ring.set_corner_radius_all(6)
	ring.set_expand_margin_all(4)
	return ring
