class_name CardData
extends Resource

enum Category {
	MATERIAL,
	PROCESS,
	TOOL,
}

@export var card_id: StringName = &""
@export var display_name: String = ""
@export var category: Category = Category.MATERIAL
@export_multiline var description: String = ""
# Leave null when using dynamic blank card frames; assign pre-rendered PNGs from assets/card/.
@export var card_texture: Texture2D = null
# Standalone item illustration from assets/items/ used in preview, objective, and fallback cards.
@export var icon: Texture2D = null
@export var consumable: bool = true


func get_category_label() -> String:
	match category:
		Category.MATERIAL:
			return "MATERIAL"
		Category.PROCESS:
			return "PROCESS"
		Category.TOOL:
			return "TOOL"
	return "UNKNOWN"
