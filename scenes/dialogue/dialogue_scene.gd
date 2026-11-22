class_name DialogueScene
extends Control

signal crafting_requested

const TYPEWRITER_CHARS_PER_SEC := 45.0

const PLAYER_EXPRESSIONS: Dictionary = {
	"kaget": preload("res://assets/sprites/player/WAH WEH WEEEY DIMANA GUA.png"),
	"biasa": preload("res://assets/sprites/player/senyum hmm.png"),
	"hehe": preload("res://assets/sprites/player/ah hehe uhh wait.png"),
	"melet": preload("res://assets/sprites/player/lel.png"),
	"ketawa": preload("res://assets/sprites/player/hahaa.png"),
}

const ALIEN_SPRITE_DEFAULT: Texture2D = preload("res://assets/sprites/alien/Rail flat.png")

# Edit or append entries here to customize the opening dialogue sequence.
const DEFAULT_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "kaget",
		"text": "Weehh apa yang terjadi?! Dimana TV-ku?!",
	},
	{
		"speaker": "???",
		"side": "left",
		"expression": "kaget",
		"text": "Halo wahai mahkluk yang disebut dalam legenda, maaf telah mengundangmu secara mendadak.",
	},
	{
		"speaker": "???",
		"side": "left",
		"expression": "biasa",
		"text": "Perkenalkan saya \\(•‿•)/. Kami hendak meminta tolong padamu. Kami mengalami keadaan yang sangat sulit, jadi kami ingin belajar bertahan hidup tanpa menggunakan sihir. Maukah kau mengajarkannya pada kami?",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"text": "Tunggu sebentar, aku baru saja berganti baju dan mau menonton sinetron \"Cinta Trigonometri\" di TV-ku. Aku belum sempat menyiapkan apapun.",
	},
	{
		"speaker": "\\(•‿•)/",
		"side": "left",
		"expression": "biasa",
		"text": "Tak masalah, kurasa kita bisa menggunakan ruangan keramat yang terkunci setelah sekian lama.",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "hehe",
		"text": "Ini gaada bedanya dengan rumah kakekku di kampung.",
	},
	{
		"speaker": "\\(•‿•)/",
		"side": "left",
		"expression": "hehe",
		"text": "Ruangan ini digunakan milyaran tahun lalu oleh mahkluk yang hanya pernah kami dengar dalam kisah legenda turun temurun. Kami harap kau bisa menemukan apapun yang kau butuhkan disini.",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "hehe",
		"text": "(Kalender di ujung ruangan menunjukkan tahun yang sama... Tahunnya sama, leluhur mereka nyulik manusia di masa depan apa begimana dah?)",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"text": "Baiklah kita mulai dari mana ya? Oh ya, siapa namamu tadi?",
	},
	{
		"speaker": "\\(•‿•)/",
		"side": "left",
		"expression": "biasa",
		"text": "\\(•‿•)/, kurasa aku penasaran apakah itu kulit aslimu? Terlihat unik sekali.",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"text": "Uhh, kupanggil kau Rail saja. Ini bukan kulitku, ini pakaian. Fungsinya memang mirip seperti kulit, digunakan untuk melindungi tubuh dari panas dan dingin, bergaya dan kesenangan bahkan digunakan sebagai status sosial.",
	},
	{
		"speaker": "Rail",
		"side": "left",
		"expression": "biasa",
		"text": "Oh benda yang menarik, bisa kau tunjukkan cara membuatnya?",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "hehe",
		"text": "Pertama-tama kita akan memerlukan kain, gunting dan alat untuk menjahit. Dan, uhh, kurasa tidak ada satupun benda itu disini.",
	},
	{
		"speaker": "Rail",
		"side": "left",
		"expression": "hehe",
		"text": "Bagaimana dengan benda-benda ini, apa ada yang kau cari disini?",
	},
	{
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"text": "Ini bahan-bahan dasar semua. Ya ampun, kurasa kita harus membuatnya dari nol. Untungnya banyak peralatan bengkel disini. Baiklah ayo kita buat alat dan bahan yang diperlukan.",
	},
]

@onready var alien_sprite: TextureRect = %AlienSprite
@onready var player_sprite: TextureRect = %PlayerSprite
@onready var dialogue_box_panel: PanelContainer = %DialogueBoxPanel
@onready var speaker_name_label: Label = %SpeakerNameLabel
@onready var dialogue_text_label: Label = %DialogueTextLabel
@onready var progress_label: Label = %ProgressLabel
@onready var continue_hint_label: Label = %ContinueHintLabel
@onready var skip_button: Button = %SkipButton

var _lines: Array[Dictionary] = []
var _current_index: int = 0
var _visible_float: float = 0.0
var _is_typing: bool = false


func _ready() -> void:
	alien_sprite.texture = ALIEN_SPRITE_DEFAULT
	skip_button.pressed.connect(advance_or_skip)
	dialogue_box_panel.gui_input.connect(_on_dialogue_box_gui_input)

	if _lines.is_empty():
		set_dialogue_lines(DEFAULT_DIALOGUE_LINES)
	else:
		_show_line(0)


func _process(delta: float) -> void:
	if not _is_typing:
		return

	var total_chars := dialogue_text_label.get_total_character_count()
	_visible_float += TYPEWRITER_CHARS_PER_SEC * delta
	var visible_count := mini(int(_visible_float), total_chars)
	dialogue_text_label.visible_characters = visible_count

	if visible_count >= total_chars:
		_finish_typewriter()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance_or_skip()
		get_viewport().set_input_as_handled()


func set_dialogue_lines(lines: Array[Dictionary]) -> void:
	_lines = lines.duplicate(true)
	_current_index = 0
	if is_node_ready():
		_show_line(0)


# First press finishes the typewriter for the active line; second press advances or starts crafting.
func advance_or_skip() -> void:
	if _lines.is_empty():
		crafting_requested.emit()
		return

	if _is_typing:
		_finish_typewriter()
		return

	var next_idx := _current_index + 1
	if next_idx >= _lines.size():
		crafting_requested.emit()
		return

	_show_line(next_idx)


func is_typing() -> bool:
	return _is_typing


func get_current_line_index() -> int:
	return _current_index


func _show_line(index: int) -> void:
	if _lines.is_empty():
		return

	_current_index = clampi(index, 0, _lines.size() - 1)
	var entry: Dictionary = _lines[_current_index]

	speaker_name_label.text = String(entry.get("speaker", ""))
	dialogue_text_label.text = String(entry.get("text", ""))
	dialogue_text_label.visible_characters = 0
	_visible_float = 0.0
	_is_typing = dialogue_text_label.get_total_character_count() > 0

	var expr_key := String(entry.get("expression", "biasa"))
	var expr_tex := PLAYER_EXPRESSIONS.get(expr_key, PLAYER_EXPRESSIONS["biasa"]) as Texture2D
	if expr_tex != null:
		player_sprite.texture = expr_tex

	var side := String(entry.get("side", "right"))
	_highlight_active_speaker(side)

	progress_label.text = "%d / %d" % [_current_index + 1, _lines.size()]
	_update_hint_text()


func _finish_typewriter() -> void:
	_is_typing = false
	dialogue_text_label.visible_characters = -1
	_update_hint_text()


func _update_hint_text() -> void:
	if _is_typing:
		continue_hint_label.text = "Klik / Skip: selesaikan teks"
	elif _current_index >= _lines.size() - 1:
		continue_hint_label.text = "Klik / Skip: mulai meracik"
	else:
		continue_hint_label.text = "Klik / Skip: dialog berikutnya"


func _highlight_active_speaker(side: String) -> void:
	if side == "left":
		alien_sprite.modulate = Color.WHITE
		player_sprite.modulate = Color(0.75, 0.75, 0.75, 1.0)
	elif side == "right":
		alien_sprite.modulate = Color(0.75, 0.75, 0.75, 1.0)
		player_sprite.modulate = Color.WHITE
	else:
		alien_sprite.modulate = Color.WHITE
		player_sprite.modulate = Color.WHITE


func _on_dialogue_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			advance_or_skip()
			dialogue_box_panel.accept_event()
