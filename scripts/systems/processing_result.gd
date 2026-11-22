class_name ProcessingResult
extends RefCounted

enum Status {
	VALIDATION_ERROR,
	SUCCESS,
	EXPERIMENT_FAILURE,
}

var status: Status = Status.VALIDATION_ERROR
var recipe_id: StringName = &""
var output_ids: Array[StringName] = []
var consumed_inputs: Array[StringName] = []
var consumed_processes: Array[StringName] = []
var consumed_tools: Array[StringName] = []
var reason: String = ""
var can_reprocess: bool = false


static func validation_error(message: String) -> ProcessingResult:
	var result := ProcessingResult.new()
	result.status = Status.VALIDATION_ERROR
	result.reason = message
	return result


static func success(
	p_recipe_id: StringName,
	p_outputs: Array[StringName],
	p_consumed_inputs: Array[StringName],
	p_consumed_processes: Array[StringName],
	p_consumed_tools: Array[StringName],
	p_reason: String
) -> ProcessingResult:
	var result := ProcessingResult.new()
	result.status = Status.SUCCESS
	result.recipe_id = p_recipe_id
	result.output_ids = p_outputs.duplicate()
	result.consumed_inputs = p_consumed_inputs.duplicate()
	result.consumed_processes = p_consumed_processes.duplicate()
	result.consumed_tools = p_consumed_tools.duplicate()
	result.reason = p_reason
	return result


static func experiment_failure(
	p_recipe_id: StringName,
	p_output_id: StringName,
	p_consumed_inputs: Array[StringName],
	p_reason: String,
	p_can_reprocess: bool
) -> ProcessingResult:
	var result := ProcessingResult.new()
	result.status = Status.EXPERIMENT_FAILURE
	result.recipe_id = p_recipe_id
	if p_output_id != &"":
		result.output_ids = [p_output_id]
	result.consumed_inputs = p_consumed_inputs.duplicate()
	result.reason = p_reason
	result.can_reprocess = p_can_reprocess
	return result
