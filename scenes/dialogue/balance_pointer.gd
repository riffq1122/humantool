class_name BalancePointer
extends Control

@export var fill_color: Color = Color("#C85A5A")
@export var outline_color: Color = Color("#23150D")


func _draw() -> void:
	var top := Vector2(size.x * 0.5, 2.0)
	var bottom_left := Vector2(2.0, size.y - 2.0)
	var bottom_right := Vector2(size.x - 2.0, size.y - 2.0)

	var pts := PackedVector2Array([top, bottom_right, bottom_left])
	draw_polygon(pts, PackedColorArray([fill_color, fill_color, fill_color]))
	draw_polyline(PackedVector2Array([top, bottom_right, bottom_left, top]), outline_color, 2.5, true)
