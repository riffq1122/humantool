extends Control

const ICON_COLOR := Color("#4E2709")


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.36
	var stroke := 4.5

	draw_arc(center, radius, deg_to_rad(25.0), deg_to_rad(175.0), 20, ICON_COLOR, stroke, true)
	draw_arc(center, radius, deg_to_rad(205.0), deg_to_rad(355.0), 20, ICON_COLOR, stroke, true)

	_draw_arrowhead(center, radius, deg_to_rad(205.0), 1.0)
	_draw_arrowhead(center, radius, deg_to_rad(25.0), 1.0)


func _draw_arrowhead(center: Vector2, radius: float, angle: float, dir: float) -> void:
	var tip := center + Vector2.from_angle(angle) * (radius + 1.0)
	var tangent := Vector2(-sin(angle), cos(angle)) * dir
	var radial := Vector2.from_angle(angle)
	var p1 := tip - tangent * 10.0 + radial * 7.5
	var p2 := tip - tangent * 10.0 - radial * 7.5
	draw_colored_polygon(PackedVector2Array([tip, p1, p2]), ICON_COLOR)
