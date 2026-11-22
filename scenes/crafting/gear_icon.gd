extends Control

const FILL_COLOR := Color("#D69A54")
const OUTLINE_COLOR := Color("#231207")
const TOOTH_COUNT := 8


func _draw() -> void:
	var center := size * 0.5
	var outer_r := minf(size.x, size.y) * 0.43
	var inner_r := outer_r * 0.72
	var hole_r := outer_r * 0.28

	var points := PackedVector2Array()
	var step := TAU / float(TOOTH_COUNT)
	for i in range(TOOTH_COUNT):
		var base := float(i) * step
		points.append(center + Vector2.from_angle(base - step * 0.24) * inner_r)
		points.append(center + Vector2.from_angle(base - step * 0.14) * outer_r)
		points.append(center + Vector2.from_angle(base + step * 0.14) * outer_r)
		points.append(center + Vector2.from_angle(base + step * 0.24) * inner_r)

	draw_colored_polygon(points, FILL_COLOR)
	var closed_outline := points.duplicate()
	closed_outline.append(points[0])
	draw_polyline(closed_outline, OUTLINE_COLOR, 2.5, true)

	draw_circle(center, hole_r, Color("#3A1D09"))
	draw_arc(center, hole_r, 0.0, TAU, 24, OUTLINE_COLOR, 2.2, true)
