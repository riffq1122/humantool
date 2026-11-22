class_name CraftingProcessor
extends RefCounted

var _validator := RecipeValidator.new()


func validate_selection(
	selected_cards: Array[CardData],
	recipes: Array[RecipeData],
	inventory: InventoryManager
) -> ProcessingResult:
	return _validator.validate(selected_cards, recipes, inventory)


func execute(
	selected_cards: Array[CardData],
	recipes: Array[RecipeData],
	inventory: InventoryManager
) -> ProcessingResult:
	var result := _validator.validate(selected_cards, recipes, inventory)
	if result.status == ProcessingResult.Status.VALIDATION_ERROR:
		return result

	for input_id in result.consumed_inputs:
		inventory.consume_material(input_id, 1)

	for process_id in result.consumed_processes:
		inventory.consume_process(process_id)

	for tool_id in result.consumed_tools:
		inventory.consume_tool(tool_id)

	for output_id in result.output_ids:
		inventory.add_material(output_id, 1)

	return result
