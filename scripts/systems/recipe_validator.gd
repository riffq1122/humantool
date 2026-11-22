class_name RecipeValidator
extends RefCounted

const MAX_SELECTED_CARDS := 5


func validate(
	selected_cards: Array[CardData],
	recipes: Array[RecipeData],
	inventory: InventoryManager
) -> ProcessingResult:
	if selected_cards.is_empty():
		return ProcessingResult.validation_error(
			"Pilih kartu dari hand terlebih dahulu sebelum menekan Craft."
		)

	if selected_cards.size() > MAX_SELECTED_CARDS:
		return ProcessingResult.validation_error(
			"Maksimal %d kartu yang bisa dipilih sekaligus." % MAX_SELECTED_CARDS
		)

	if inventory == null:
		return ProcessingResult.validation_error("InventoryManager belum tersedia.")

	var selected_ids: Array[StringName] = []
	var material_counts: Dictionary = {}
	var has_material_category := false
	var has_process_category := false
	var has_tool_category := false

	for card in selected_cards:
		if card == null or card.card_id == &"":
			return ProcessingResult.validation_error("Terdapat kartu tidak valid dalam pilihan.")

		selected_ids.append(card.card_id)
		match card.category:
			CardData.Category.MATERIAL:
				has_material_category = true
				material_counts[card.card_id] = int(material_counts.get(card.card_id, 0)) + 1
			CardData.Category.PROCESS:
				has_process_category = true
				if not inventory.has_process(card.card_id):
					return ProcessingResult.validation_error(
						"Proses '%s' belum tersedia di inventory." % card.display_name
					)
			CardData.Category.TOOL:
				has_tool_category = true
				if not inventory.has_tool(card.card_id):
					return ProcessingResult.validation_error(
						"Tool '%s' tidak tersedia di inventory." % card.display_name
					)

	for mat_id in material_counts.keys():
		var required_qty: int = int(material_counts[mat_id])
		if not inventory.has_material(mat_id, required_qty):
			var mat_card := inventory.get_card(mat_id)
			var mat_name := mat_card.display_name if mat_card != null else String(mat_id)
			return ProcessingResult.validation_error(
				"Stok '%s' tidak mencukupi (butuh %d)." % [mat_name, required_qty]
			)

	var closest_recipe_with_extra: RecipeData = null

	for recipe in recipes:
		if recipe == null or recipe.required_cards.is_empty():
			continue

		var is_match := false
		if recipe.allow_extra_cards:
			is_match = _contains_all_multiset(selected_ids, recipe.required_cards)
		else:
			is_match = _same_multiset(selected_ids, recipe.required_cards)
			if not is_match and _contains_all_multiset(selected_ids, recipe.required_cards):
				closest_recipe_with_extra = recipe

		if is_match:
			return _build_success_result(recipe, selected_cards, inventory)

	for recipe in recipes:
		if recipe == null:
			continue
		for failure in recipe.failure_outcomes:
			if failure == null or failure.trigger_cards.is_empty():
				continue
			if _same_multiset(selected_ids, failure.trigger_cards):
				var consumed_inputs := _collect_consumable_materials(
					failure.trigger_cards,
					selected_cards,
					inventory
				)
				return ProcessingResult.experiment_failure(
					recipe.recipe_id,
					failure.output_card_id,
					consumed_inputs,
					failure.cause_and_effect_reason,
					failure.can_reprocess
				)

	if closest_recipe_with_extra != null:
		return ProcessingResult.validation_error(
			"Terlalu banyak kartu terpilih untuk resep '%s'. Lepas kartu tambahan yang tidak diperlukan." % closest_recipe_with_extra.recipe_name
		)

	if not has_material_category:
		return ProcessingResult.validation_error(
			"Belum ada kartu Material terpilih. Pilih bahan yang ingin diolah."
		)
	if not has_process_category:
		return ProcessingResult.validation_error(
			"Belum ada kartu Process terpilih. Pilih proses pengolahan yang sesuai."
		)
	if not has_tool_category:
		return ProcessingResult.validation_error(
			"Belum ada kartu Tool terpilih. Pilih alat yang dibutuhkan proses."
		)

	for recipe in recipes:
		if recipe == null or recipe.required_cards.is_empty():
			continue
		if _contains_all_multiset(recipe.required_cards, selected_ids) and selected_ids.size() < recipe.required_cards.size():
			return ProcessingResult.validation_error(
				"Kombinasi untuk '%s' belum lengkap. Tambahkan kartu lain yang masih kurang." % recipe.recipe_name
			)

	return ProcessingResult.validation_error(
		"Kombinasi kartu ini belum cocok dengan resep yang tersedia. Periksa kembali bahan, proses, dan alatnya."
	)


func _build_success_result(
	recipe: RecipeData,
	selected_cards: Array[CardData],
	inventory: InventoryManager
) -> ProcessingResult:
	var consumed_inputs := _collect_consumable_materials(
		recipe.required_cards,
		selected_cards,
		inventory
	)
	var consumed_processes: Array[StringName] = []

	if recipe.consume_process:
		for req_id in recipe.required_cards:
			var card := _resolve_card(req_id, selected_cards, inventory)
			if card != null and card.category == CardData.Category.PROCESS:
				consumed_processes.append(req_id)

	var consumed_tools: Array[StringName] = recipe.consume_tools.duplicate()
	return ProcessingResult.success(
		recipe.recipe_id,
		recipe.outputs,
		consumed_inputs,
		consumed_processes,
		consumed_tools,
		recipe.stem_explanation
	)


func _collect_consumable_materials(
	card_ids: Array[StringName],
	selected_cards: Array[CardData],
	inventory: InventoryManager
) -> Array[StringName]:
	var consumed: Array[StringName] = []
	for id in card_ids:
		var card := _resolve_card(id, selected_cards, inventory)
		if card != null and card.category == CardData.Category.MATERIAL and card.consumable:
			consumed.append(id)
	return consumed


func _resolve_card(
	card_id: StringName,
	selected_cards: Array[CardData],
	inventory: InventoryManager
) -> CardData:
	var card := inventory.get_card(card_id)
	if card != null:
		return card
	for selected in selected_cards:
		if selected != null and selected.card_id == card_id:
			return selected
	return null


func _count_ids(ids: Array[StringName]) -> Dictionary:
	var counts: Dictionary = {}
	for id in ids:
		counts[id] = int(counts.get(id, 0)) + 1
	return counts


func _same_multiset(a: Array[StringName], b: Array[StringName]) -> bool:
	if a.size() != b.size():
		return false
	var counts_a := _count_ids(a)
	var counts_b := _count_ids(b)
	if counts_a.size() != counts_b.size():
		return false
	for key in counts_a.keys():
		if int(counts_a[key]) != int(counts_b.get(key, 0)):
			return false
	return true


func _contains_all_multiset(superset: Array[StringName], subset: Array[StringName]) -> bool:
	if superset.size() < subset.size():
		return false
	var superset_counts := _count_ids(superset)
	var subset_counts := _count_ids(subset)
	for key in subset_counts.keys():
		if int(superset_counts.get(key, 0)) < int(subset_counts[key]):
			return false
	return true
