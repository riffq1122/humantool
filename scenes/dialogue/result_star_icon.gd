class_name ResultStarIcon
extends Control

const STAR_TEX: Texture2D = preload("res://assets/ui/negotiation/result_star.png")

@export var is_earned: bool = true:
	set(value):
		is_earned = value
		_ensure_nodes()
		_stop_star_tween()
		_fill_rect.visible = value
		_fill_rect.scale = Vector2.ONE
		_fill_rect.rotation_degrees = 0.0
		_fill_rect.modulate = Color.WHITE

var _silhouette_rect: TextureRect = null
var _fill_rect: TextureRect = null
var _star_tween: Tween = null


func _ready() -> void:
	_ensure_nodes()
	_fill_rect.visible = is_earned


func prepare_for_reveal(will_earn: bool) -> void:
	_ensure_nodes()
	_stop_star_tween()
	is_earned = will_earn
	_fill_rect.visible = false
	_fill_rect.scale = Vector2.ZERO
	_fill_rect.rotation_degrees = -24.0
	_fill_rect.modulate = Color(1.0, 1.0, 1.0, 0.0)


func play_pop_in(delay_sec: float = 0.0) -> void:
	_ensure_nodes()
	_stop_star_tween()
	if not is_earned:
		_fill_rect.visible = false
		return

	_fill_rect.visible = false
	_star_tween = create_tween()
	if delay_sec > 0.0:
		_star_tween.tween_interval(delay_sec)
	_star_tween.tween_callback(func() -> void:
		_fill_rect.visible = true
		_fill_rect.pivot_offset = size * 0.5
		_fill_rect.scale = Vector2(0.1, 0.1)
		_fill_rect.rotation_degrees = -24.0
		_fill_rect.modulate = Color(1.0, 1.0, 1.0, 0.0)
	)
	_star_tween.tween_property(_fill_rect, "scale", Vector2.ONE, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_star_tween.parallel().tween_property(_fill_rect, "rotation_degrees", 0.0, 0.36).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_star_tween.parallel().tween_property(_fill_rect, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _ensure_nodes() -> void:
	if _silhouette_rect != null and _fill_rect != null:
		return

	_silhouette_rect = TextureRect.new()
	_silhouette_rect.name = "StarSilhouette"
	_silhouette_rect.texture = STAR_TEX
	_silhouette_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_silhouette_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_silhouette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_silhouette_rect.modulate = Color(0.14, 0.09, 0.04, 0.62)
	_silhouette_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_silhouette_rect)

	_fill_rect = TextureRect.new()
	_fill_rect.name = "StarFill"
	_fill_rect.texture = STAR_TEX
	_fill_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fill_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_fill_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fill_rect)


func _stop_star_tween() -> void:
	if _star_tween != null and _star_tween.is_valid():
		_star_tween.kill()
	_star_tween = null
