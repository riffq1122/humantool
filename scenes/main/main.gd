extends Control

enum StoryStage {
	OPENING,
	POST_BAJU,
	STAGE2_INTRO,
	POST_CERMIN,
	STAGE3_INTRO,
	POST_LIPSTIK,
}

const DIALOGUE_SCENE_PATH := "res://scenes/dialogue/dialogue_scene.tscn"
const CRAFTING_SCENE_PATH := "res://scenes/crafting/crafting_scene.tscn"
const MAIN_MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const LOADING_SCREEN_SCENE := preload("res://scenes/ui/loading_screen.tscn")
const ROUTE_MENU := &"menu"

@onready var scene_container: Control = $SceneContainer

var _loading_screen: LoadingScreen = null
var _is_switching := false
var _current_scene: Node = null
var _active_route: StringName = &""
var _story_stage: StoryStage = StoryStage.OPENING
var _transition_rect: ColorRect = null
var _transition_tween: Tween = null


func _ready() -> void:
	_transition_rect = ColorRect.new()
	_transition_rect.name = "SceneTransitionFade"
	_transition_rect.color = Color(0.04, 0.03, 0.02, 1.0)
	_transition_rect.z_index = 200
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_transition_rect)

	_loading_screen = LOADING_SCREEN_SCENE.instantiate() as LoadingScreen
	_loading_screen.z_index = 195
	add_child(_loading_screen)

	show_main_menu()


func show_main_menu() -> void:
	_free_current_scene()
	_active_route = ROUTE_MENU
	var menu := MAIN_MENU_SCENE.instantiate()
	menu.connect(&"play_requested", _on_menu_play_requested)
	scene_container.add_child(menu)
	_current_scene = menu
	_play_fade_in_transition()


func _on_menu_play_requested() -> void:
	_story_stage = StoryStage.OPENING
	show_dialogue_scene()


func set_story_stage(stage: StoryStage) -> void:
	_story_stage = stage


func get_story_stage() -> StoryStage:
	return _story_stage


func show_dialogue_scene() -> void:
	if _is_switching:
		return
	await _switch_scene(
		&"dialogue",
		DIALOGUE_SCENE_PATH,
		&"crafting_requested",
		show_crafting_scene,
		"[Placeholder Tahap 3] Dialogue Scene",
		"Scene dialog belum dibuat (Tahap 4). Klik tombol di bawah untuk menguji perpindahan ke Crafting Scene.",
		"Buka Crafting Scene"
	)
	if is_instance_valid(_current_scene):
		if _current_scene.has_signal(&"next_stage_requested"):
			_current_scene.connect(&"next_stage_requested", _on_next_stage_requested)
		if _current_scene.has_signal(&"main_menu_requested"):
			_current_scene.connect(&"main_menu_requested", show_main_menu)
		match _story_stage:
			StoryStage.POST_BAJU:
				if _current_scene.has_method("start_post_baju_sequence"):
					_current_scene.call("start_post_baju_sequence")
			StoryStage.STAGE2_INTRO:
				if _current_scene.has_method("start_stage2_intro_sequence"):
					_current_scene.call("start_stage2_intro_sequence")
			StoryStage.POST_CERMIN:
				if _current_scene.has_method("start_post_cermin_sequence"):
					_current_scene.call("start_post_cermin_sequence")
			StoryStage.STAGE3_INTRO:
				if _current_scene.has_method("start_stage3_intro_sequence"):
					_current_scene.call("start_stage3_intro_sequence")
			StoryStage.POST_LIPSTIK:
				if _current_scene.has_method("start_post_lipstik_sequence"):
					_current_scene.call("start_post_lipstik_sequence")


func _on_next_stage_requested() -> void:
	if _story_stage in [StoryStage.STAGE2_INTRO, StoryStage.POST_CERMIN]:
		_story_stage = StoryStage.STAGE3_INTRO
	else:
		_story_stage = StoryStage.STAGE2_INTRO
	show_dialogue_scene()


func show_crafting_scene() -> void:
	if _is_switching:
		return
	await _switch_scene(
		&"crafting",
		CRAFTING_SCENE_PATH,
		&"dialogue_requested",
		show_dialogue_scene,
		"[Placeholder Tahap 3] Crafting Scene",
		"Scene crafting belum dibuat (Tahap 5). Klik tombol di bawah untuk menguji kembali ke Dialogue Scene.",
		"Kembali ke Dialogue Scene"
	)
	if is_instance_valid(_current_scene):
		if _current_scene.has_signal(&"craft_completed"):
			_current_scene.connect(&"craft_completed", _on_crafting_craft_completed)
		if _current_scene.has_method("setup_stage"):
			var stage_num := 1
			if _story_stage in [StoryStage.STAGE3_INTRO, StoryStage.POST_LIPSTIK]:
				stage_num = 3
			elif _story_stage in [StoryStage.STAGE2_INTRO, StoryStage.POST_CERMIN]:
				stage_num = 2
			_current_scene.call("setup_stage", stage_num)


func _on_crafting_craft_completed(result: ProcessingResult) -> void:
	if result == null or result.status != ProcessingResult.Status.SUCCESS:
		return
	if result.output_ids.has(&"baju"):
		_story_stage = StoryStage.POST_BAJU
	elif result.output_ids.has(&"cermin"):
		_story_stage = StoryStage.POST_CERMIN
	elif result.output_ids.has(&"lipstik"):
		_story_stage = StoryStage.POST_LIPSTIK


func _switch_scene(
	route_name: StringName,
	scene_path: String,
	expected_signal: StringName,
	signal_handler: Callable,
	placeholder_title: String,
	placeholder_body: String,
	placeholder_cta: String
) -> void:
	_is_switching = true
	await _loading_screen.show_screen()

	_free_current_scene()
	_active_route = route_name

	var next_scene: Node = null
	var packed_scene := await _load_scene_with_progress(scene_path)
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
	_is_switching = false
	# Not awaited: callers configure the new scene while the loader fades out.
	_loading_screen.hide_screen()


## Loads a scene on a background thread and feeds its real progress to the loader.
## Returns null when the scene is missing or fails, so the caller shows a placeholder.
func _load_scene_with_progress(scene_path: String) -> PackedScene:
	var packed_scene: PackedScene = null
	if ResourceLoader.exists(scene_path) and ResourceLoader.load_threaded_request(scene_path) == OK:
		var progress: Array = []
		var status := ResourceLoader.load_threaded_get_status(scene_path, progress)
		while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_loading_screen.set_target_progress(float(progress[0]) if not progress.is_empty() else 0.0)
			await get_tree().process_frame
			status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			packed_scene = ResourceLoader.load_threaded_get(scene_path) as PackedScene
		else:
			push_error("Gagal memuat scene: %s (status %d)" % [scene_path, status])
	_loading_screen.set_target_progress(1.0)
	await _loading_screen.wait_until_filled()
	return packed_scene


func _free_current_scene() -> void:
	if not is_instance_valid(_current_scene):
		return
	# Detach before queue_free so the outgoing scene cannot receive input this frame.
	scene_container.remove_child(_current_scene)
	_current_scene.queue_free()
	_current_scene = null


func _play_fade_in_transition() -> void:
	if _transition_rect == null:
		return
	if _transition_tween != null and _transition_tween.is_running():
		_transition_tween.kill()
	_transition_rect.color.a = 1.0
	_transition_tween = create_tween()
	_transition_tween.tween_property(_transition_rect, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


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
