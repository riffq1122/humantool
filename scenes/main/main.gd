extends Control

const DIALOGUE_SCENE_PATH := "res://scenes/dialogue/dialogue_scene.tscn"
const CRAFTING_SCENE_PATH := "res://scenes/crafting/crafting_scene.tscn"

@onready var scene_container: Control = $SceneContainer

var _current_scene: Node = null
var _active_route: StringName = &""


func _ready() -> void:
	show_dialogue_scene()


func show_dialogue_scene() -> void:
	_switch_scene(
		&"dialogue",
		DIALOGUE_SCENE_PATH,
		&"crafting_requested",
		show_crafting_scene,
		"[Placeholder Tahap 3] Dialogue Scene",
		"Scene dialog belum dibuat (Tahap 4). Klik tombol di bawah untuk menguji perpindahan ke Crafting Scene.",
		"Buka Crafting Scene"
	)


func show_crafting_scene() -> void:
	_switch_scene(
		&"crafting",
		CRAFTING_SCENE_PATH,
		&"dialogue_requested",
		show_dialogue_scene,
		"[Placeholder Tahap 3] Crafting Scene",
		"Scene crafting belum dibuat (Tahap 5). Klik tombol di bawah untuk menguji kembali ke Dialogue Scene.",
		"Kembali ke Dialogue Scene"
	)


func _switch_scene(
	route_name: StringName,
	scene_path: String,
	expected_signal: StringName,
	signal_handler: Callable,
	placeholder_title: String,
	placeholder_body: String,
	placeholder_cta: String
) -> void:
	if is_instance_valid(_current_scene):
		# Detach before queue_free so the outgoing scene cannot receive input this frame.
		scene_container.remove_child(_current_scene)
		_current_scene.queue_free()
		_current_scene = null

	_active_route = route_name

	var next_scene: Node = null
	if ResourceLoader.exists(scene_path):
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene != null:
			next_scene = packed_scene.instantiate()
			if next_scene.has_signal(expected_signal):
				next_scene.connect(expected_signal, signal_handler)

	if next_scene == null:
		next_scene = _create_placeholder_scene(
			placeholder_title,
			placeholder_body,
			placeholder_cta,
			signal_handler
		)

	scene_container.add_child(next_scene)
	_current_scene = next_scene


func _create_placeholder_scene(
	title_text: String,
	body_text: String,
	button_text: String,
	on_pressed: Callable
) -> Control:
	var root := Control.new()
	root.name = "PlaceholderScene"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.color = Color("#1F2421")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(560, 0)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#2B322E")
	card_style.border_color = Color("#4B5750")
	card_style.set_border_width_all(2)
	card_style.set_corner_radius_all(8)
	card.add_theme_stylebox_override("panel", card_style)
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = title_text
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color("#F4EFE6"))
	vbox.add_child(title_label)

	var body_label := Label.new()
	body_label.name = "BodyLabel"
	body_label.text = body_text
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 16)
	body_label.add_theme_color_override("font_color", Color("#D8D2C7"))
	vbox.add_child(body_label)

	var action_button := Button.new()
	action_button.name = "SwitchButton"
	action_button.text = button_text
	action_button.custom_minimum_size = Vector2(0, 44)
	action_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_button_styles(action_button)
	action_button.pressed.connect(on_pressed)
	vbox.add_child(action_button)

	# Defer focus until the placeholder enters the tree so Enter/Space works at once.
	action_button.call_deferred("grab_focus")
	return root


func _apply_button_styles(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#3A443E")
	normal.border_color = Color("#6E7B72")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.set_content_margin_all(10)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#47544C")
	hover.border_color = Color("#98A79D")

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#242B27")

	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = Color("#D98A3C")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("#F4EFE6"))
	button.add_theme_color_override("font_hover_color", Color("#FFFFFF"))
	button.add_theme_color_override("font_focus_color", Color("#FFFFFF"))
	button.add_theme_color_override("font_pressed_color", Color("#D8D2C7"))
