class_name FailureOutcomeData
extends Resource

@export var failure_id: StringName = &""
@export var trigger_cards: Array[StringName] = []
@export var output_card_id: StringName = &""
@export var can_reprocess: bool = true
@export_multiline var cause_and_effect_reason: String = ""
