class_name InventoryManager
extends Node

signal inventory_changed

var _card_registry: Dictionary = {}
var _material_counts: Dictionary = {}
var _unlocked_processes: Array[StringName] = []
var _owned_tools: Array[StringName] = []


func register_cards(cards: Array[CardData]) -> void:
	for card in cards:
		if card != null and card.card_id != &"":
			_card_registry[card.card_id] = card


func setup_initial_inventory(
	initial_materials: Dictionary,
	initial_processes: Array[StringName],
	initial_tools: Array[StringName]
) -> void:
	_material_counts.clear()
	for card_id in initial_materials.keys():
		var amount: int = int(initial_materials[card_id])
		if amount > 0:
			_material_counts[StringName(card_id)] = amount

	_unlocked_processes = initial_processes.duplicate()
	_owned_tools = initial_tools.duplicate()
	inventory_changed.emit()


func get_card(card_id: StringName) -> CardData:
	return _card_registry.get(card_id, null) as CardData


func get_material_count(card_id: StringName) -> int:
	return int(_material_counts.get(card_id, 0))


func has_material(card_id: StringName, amount: int = 1) -> bool:
	return get_material_count(card_id) >= amount


func add_material(card_id: StringName, amount: int = 1) -> void:
	if card_id == &"" or amount <= 0:
		return
	_material_counts[card_id] = get_material_count(card_id) + amount
	inventory_changed.emit()


func consume_material(card_id: StringName, amount: int = 1) -> bool:
	if not has_material(card_id, amount):
		return false
	var remaining := get_material_count(card_id) - amount
	if remaining <= 0:
		_material_counts.erase(card_id)
	else:
		_material_counts[card_id] = remaining
	inventory_changed.emit()
	return true


func has_process(card_id: StringName) -> bool:
	return _unlocked_processes.has(card_id)


func consume_process(card_id: StringName) -> bool:
	var idx := _unlocked_processes.find(card_id)
	if idx == -1:
		return false
	_unlocked_processes.remove_at(idx)
	inventory_changed.emit()
	return true


func has_tool(card_id: StringName) -> bool:
	return _owned_tools.has(card_id)


func consume_tool(card_id: StringName) -> bool:
	var idx := _owned_tools.find(card_id)
	if idx == -1:
		return false
	_owned_tools.remove_at(idx)
	inventory_changed.emit()
	return true


func get_material_stocks_snapshot() -> Dictionary:
	return _material_counts.duplicate()


# Curated pool keeps hand construction decoupled from UI so draw/discard can plug in later.
func get_curated_hand_cards(curated_ids: Array[StringName], max_count: int = 7) -> Array[CardData]:
	var result: Array[CardData] = []
	if curated_ids.is_empty():
		var fallback: Array[CardData] = []
		fallback.append_array(get_available_materials())
		fallback.append_array(get_available_processes())
		fallback.append_array(get_available_tools())
		for card in fallback:
			if result.size() >= max_count:
				break
			result.append(card)
		return result

	for card_id in curated_ids:
		if result.size() >= max_count:
			break
		var card := get_card(card_id)
		if card != null:
			result.append(card)
	return result


func get_available_materials() -> Array[CardData]:
	var result: Array[CardData] = []
	for card_id in _material_counts.keys():
		if get_material_count(card_id) > 0:
			var card := get_card(card_id)
			if card != null:
				result.append(card)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name < b.display_name)
	return result


func get_available_processes() -> Array[CardData]:
	var result: Array[CardData] = []
	for card_id in _unlocked_processes:
		var card := get_card(card_id)
		if card != null:
			result.append(card)
	return result


func get_available_tools() -> Array[CardData]:
	var result: Array[CardData] = []
	for card_id in _owned_tools:
		var card := get_card(card_id)
		if card != null:
			result.append(card)
	return result
