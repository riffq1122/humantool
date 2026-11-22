class_name LoadingScreen
extends Control
## Full-screen loader shown between major scenes. The bar follows real
## ResourceLoader progress, eased so very fast loads do not just flash.

signal filled

## Minimum time for the bar to go from 0 to 100%.
const MIN_FILL_SECONDS := 0.9
const FADE_IN_SECONDS := 0.2
const FADE_OUT_SECONDS := 0.3
const BAR_CAP_WIDTH := 23.0

@onready var _bar: TextureProgressBar = %ProgressBar
@onready var _walker: TextureRect = %Walker
@onready var _status_label: Label = %StatusLabel

var _target_progress := 0.0
var _shown_progress := 0.0
var _filled_emitted := false
var _walk_time := 0.0
var _fade_tween: Tween = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_refresh_visuals()


func show_screen() -> void:
	_target_progress = 0.0
	_shown_progress = 0.0
	_filled_emitted = false
	_refresh_visuals()
	visible = true
	modulate.a = 0.0
	_restart_fade(1.0, FADE_IN_SECONDS)
	await _fade_tween.finished


func hide_screen() -> void:
	_restart_fade(0.0, FADE_OUT_SECONDS)
	await _fade_tween.finished
	visible = false


func set_target_progress(value: float) -> void:
	_target_progress = maxf(_target_progress, clampf(value, 0.0, 1.0))


func wait_until_filled() -> void:
	if _filled_emitted:
		return
	await filled


func _process(delta: float) -> void:
	if not visible:
		return
	_walk_time += delta
	_shown_progress = move_toward(_shown_progress, _target_progress, delta / MIN_FILL_SECONDS)
	_refresh_visuals()
	if _shown_progress >= 1.0 and not _filled_emitted:
		_filled_emitted = true
		filled.emit()


func _refresh_visuals() -> void:
	if _bar == null:
		return
	_bar.value = _shown_progress * _bar.max_value
	_status_label.text = "Loading... %d%%" % int(round(_shown_progress * 100.0))

	# Rail walks along the top of the bar, staying just behind the fill edge.
	var track_width := _bar.size.x - BAR_CAP_WIDTH * 2.0
	var fill_edge_x := _bar.position.x + BAR_CAP_WIDTH + track_width * _shown_progress
	var step := sin(_walk_time * 12.0)
	_walker.position.x = fill_edge_x - _walker.size.x * 0.5 - 20.0
	_walker.position.y = _bar.position.y - _walker.size.y + 14.0 - absf(step) * 6.0
	_walker.rotation = deg_to_rad(step * 4.0)


func _restart_fade(to_alpha: float, duration: float) -> void:
	if _fade_tween != null and _fade_tween.is_running():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", to_alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
