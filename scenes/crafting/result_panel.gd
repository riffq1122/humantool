class_name ResultPanel
extends PanelContainer

const COLOR_IDLE := Color("#CBC4B6")
const COLOR_SUCCESS := Color("#6BBF7A")
const COLOR_VALIDATION := Color("#E0B454")
const COLOR_FAILURE := Color("#E06C5A")

@onready var status_label: Label = %StatusLabel
@onready var output_label: Label = %OutputLabel
@onready var inventory_stock_label: Label = %InventoryStockLabel
@onready var feedback_text: RichTextLabel = %FeedbackText


func _ready() -> void:
	reset_display()


func reset_display(inventory: InventoryManager = null) -> void:
	status_label.text = "Status: Siap Meracik"
	status_label.add_theme_color_override("font_color", COLOR_IDLE)
	output_label.text = "Output: -"
	feedback_text.text = "Pilih hingga 5 kartu dari hand di bawah (Material, Process, dan Tool), lalu tekan Craft / Process."
	update_inventory_summary(inventory)


func show_limit_warning(max_selected: int) -> void:
	status_label.text = "Status: Batas Pilihan (%d Kartu)" % max_selected
	status_label.add_theme_color_override("font_color", COLOR_VALIDATION)
	feedback_text.text = "Maksimal %d kartu dapat dipilih sekaligus. Klik kartu yang sudah terangkat untuk membatalkan pilihannya." % max_selected


func show_result(result: ProcessingResult, inventory: InventoryManager) -> void:
	if result == null:
		reset_display(inventory)
		return

	var output_names := _format_outputs(result.output_ids, inventory)

	match result.status:
		ProcessingResult.Status.SUCCESS:
			status_label.text = "Status: Berhasil Diracik"
			status_label.add_theme_color_override("font_color", COLOR_SUCCESS)
			output_label.text = "Output: %s (masuk Inventory)" % output_names
			feedback_text.text = result.reason
		ProcessingResult.Status.VALIDATION_ERROR:
			status_label.text = "Status: Kombinasi Belum Cocok"
			status_label.add_theme_color_override("font_color", COLOR_VALIDATION)
			output_label.text = "Output: Tidak diproses (bahan aman)"
			feedback_text.text = result.reason
		ProcessingResult.Status.EXPERIMENT_FAILURE:
			status_label.text = "Status: Produk Cacat (Eksperimen)"
			status_label.add_theme_color_override("font_color", COLOR_FAILURE)
			output_label.text = "Output: %s (masuk Inventory)" % output_names
			var reprocess_note := "\n\nCatatan: Hasil ini dapat diolah ulang dengan kombinasi Smelting yang tepat." if result.can_reprocess else ""
			feedback_text.text = result.reason + reprocess_note

	update_inventory_summary(inventory)


func update_inventory_summary(inventory: InventoryManager) -> void:
	if inventory == null:
		inventory_stock_label.text = "Hasil di Inventory: Iron Ingot x0"
		return

	var ingot_count := inventory.get_material_count(&"iron_ingot")
	var crushed_count := inventory.get_material_count(&"crushed_iron_ore")
	var summary := "Hasil di Inventory: Iron Ingot x%d" % ingot_count
	if crushed_count > 0:
		summary += " | Crushed Iron Ore x%d" % crushed_count
	inventory_stock_label.text = summary


func _format_outputs(output_ids: Array[StringName], inventory: InventoryManager) -> String:
	if output_ids.is_empty():
		return "-"
	var names: PackedStringArray = []
	for id in output_ids:
		var card := inventory.get_card(id) if inventory != null else null
		names.append(card.display_name if card != null else String(id))
	return ", ".join(names)
