class_name RecipeData
extends Resource

@export var recipe_id: StringName = &""
@export var recipe_name: String = ""
# Order-independent set of card IDs required to trigger this recipe.
@export var required_cards: Array[StringName] = []
# Keep false by default so unrelated extra cards cannot accidentally satisfy a recipe.
@export var allow_extra_cards: bool = false
@export var consume_process: bool = false
# Tools stay reusable unless explicitly listed here.
@export var consume_tools: Array[StringName] = []
@export var outputs: Array[StringName] = []
@export var failure_outcomes: Array[FailureOutcomeData] = []
@export_multiline var stem_explanation: String = ""
