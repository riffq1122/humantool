class_name ShowcaseBurst
extends Control

@export var ray_count: int = 12
@export var rotation_speed: float = 0.38

var _angle: float = 0.0
var _time: float = 0.0


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	_angle = fmod(_angle + rotation_speed * delta, TAU)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var max_radius := minf(size.x, size.y) * 0.5
	if max_radius <= 1.0:
		return

	var pulse := 1.0 + 0.045 * sin(_time * 2.4)
	draw_circle(center, max_radius * 0.64 * pulse, Color(1.0, 0.95, 0.76, 0.11))
	draw_circle(center, max_radius * 0.46 * pulse, Color(1.0, 0.96, 0.80, 0.18))
	draw_circle(center, max_radius * 0.30 * pulse, Color(1.0, 0.98, 0.88, 0.24))

	var step := TAU / float(maxi(ray_count, 1))
	var primary_half := 0.105
	var primary_center := Color(1.0, 0.95, 0.74, 0.36)
	var primary_tip := Color(1.0, 0.95, 0.74, 0.0)

	var secondary_half := 0.065
	var secondary_center := Color(1.0, 0.98, 0.86, 0.22)
	var secondary_tip := Color(1.0, 0.98, 0.86, 0.0)

	for i in range(ray_count):
		var a1 := _angle + step * float(i)
		var p1a := center + Vector2.from_angle(a1 - primary_half) * max_radius
		var p1b := center + Vector2.from_angle(a1 + primary_half) * max_radius
		draw_polygon(
			PackedVector2Array([center, p1a, p1b]),
			PackedColorArray([primary_center, primary_tip, primary_tip])
		)

		var a2 := -_angle * 0.55 + step * (float(i) + 0.5)
		var p2a := center + Vector2.from_angle(a2 - secondary_half) * (max_radius * 0.86)
		var p2b := center + Vector2.from_angle(a2 + secondary_half) * (max_radius * 0.86)
		draw_polygon(
			PackedVector2Array([center, p2a, p2b]),
			PackedColorArray([secondary_center, secondary_tip, secondary_tip])
		)
