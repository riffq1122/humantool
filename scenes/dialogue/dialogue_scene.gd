class_name DialogueScene
extends Control

signal crafting_requested
signal next_stage_requested
signal main_menu_requested

const TYPEWRITER_CHARS_PER_SEC := 45.0

const INITIAL_IRON_OFFER := 3
const TARGET_IRON_OFFER := 5
const MIN_IRON_OFFER := 0
const MAX_IRON_OFFER := 10
const RANDOM_OVERPRICED_MIN := 6
const RANDOM_OVERPRICED_MAX := 10
const MAX_NEGOTIATION_LIVES := 2

const SCALE_PIVOT := Vector2(210.0, 144.4)
const LEFT_HOOK_OFFSET := Vector2(-149.3, 54.1)
const RIGHT_HOOK_OFFSET := Vector2(149.3, 54.1)
const RIGHT_PAN_BASE_POS := Vector2(210.0, 0.0)
const BALANCE_TRACK_WIDTH := 432.0
const POINTER_WIDTH := 24.0

const IRON_PILE_LAYOUT: Array[Dictionary] = [
	{"pos": Vector2(28.0, 44.0), "size": Vector2(44.0, 44.0)},
	{"pos": Vector2(8.0, 47.0), "size": Vector2(40.0, 40.0)},
	{"pos": Vector2(52.0, 47.0), "size": Vector2(40.0, 40.0)},
	{"pos": Vector2(20.0, 49.0), "size": Vector2(38.0, 38.0)},
	{"pos": Vector2(40.0, 28.0), "size": Vector2(38.0, 38.0)},
	{"pos": Vector2(14.0, 28.0), "size": Vector2(36.0, 36.0)},
	{"pos": Vector2(52.0, 30.0), "size": Vector2(36.0, 36.0)},
	{"pos": Vector2(28.0, 14.0), "size": Vector2(36.0, 36.0)},
	{"pos": Vector2(18.0, 10.0), "size": Vector2(32.0, 32.0)},
	{"pos": Vector2(46.0, 12.0), "size": Vector2(32.0, 32.0)},
]

const BACKGROUNDS: Dictionary = {
	"1a": preload("res://assets/backgrounds/cutscene narasi opening game (story)/1a.png"),
	"1b": preload("res://assets/backgrounds/cutscene narasi opening game (story)/1b.png"),
	"1c": preload("res://assets/backgrounds/cutscene narasi opening game (story)/1c.png"),
	"1d": preload("res://assets/backgrounds/cutscene narasi opening game (story)/1d.png"),
	"aula_ritual": preload("res://assets/backgrounds/aula ritual.png"),
	"percakapan": preload("res://assets/backgrounds/background percakapan.png"),
	"lipstik_1_cermin": preload("res://assets/backgrounds/cutscene narasi opening game (story)/lipstik/rail_menor_cermin.jpg"),
	"lipstik_2_mengecat": preload("res://assets/backgrounds/cutscene narasi opening game (story)/lipstik/rail_mengecat.jpg"),
	"lipstik_3_menor": preload("res://assets/backgrounds/cutscene narasi opening game (story)/lipstik/rail_menor_full.jpg"),
}

const PORTAL_TEXTURE: Texture2D = preload("res://assets/backgrounds/cutscene narasi opening game (story)/the portal.png")
const ILMUAN_SPAWN_TEXTURE: Texture2D = preload("res://assets/backgrounds/cutscene narasi opening game (story)/ilmuan has spawned.png")
const IRON_ORE_TEXTURE: Texture2D = preload("res://assets/items/iron ore.png")
const BAJU_ITEM_TEXTURE: Texture2D = preload("res://assets/items/baju.png")
const CERMIN_ITEM_TEXTURE: Texture2D = preload("res://assets/items/cermin.png")
const LIPSTIK_ITEM_TEXTURE: Texture2D = preload("res://assets/items/lipstik jadi.png")
const STAMP_DISEPAKATI_TEX: Texture2D = preload("res://assets/ui/negotiation/stamp_disepakati.png")
const STAMP_GAGAL_TEX: Texture2D = preload("res://assets/ui/negotiation/stamp_gagal.png")

const PLAYER_EXPRESSIONS: Dictionary = {
	"kaget": preload("res://assets/sprites/player/WAH WEH WEEEY DIMANA GUA.png"),
	"biasa": preload("res://assets/sprites/player/senyum hmm.png"),
	"hehe": preload("res://assets/sprites/player/ah hehe uhh wait.png"),
	"melet": preload("res://assets/sprites/player/lel.png"),
	"ketawa": preload("res://assets/sprites/player/hahaa.png"),
}

const ALIEN_EXPRESSIONS: Dictionary = {
	"biasa": preload("res://assets/sprites/alien/Rail flat.png"),
	"tanya": preload("res://assets/sprites/alien/rail hah heh hoh.png"),
	"senang": preload("res://assets/sprites/alien/rail senang.png"),
	"kaget": preload("res://assets/sprites/alien/rail soak.png"),
	"baju": preload("res://assets/sprites/alien/rail muslimah.png"),
	"cermin": preload("res://assets/ui/main_menu/rail_cermin.png"),
	"menor": preload("res://assets/sprites/alien/rail menor.png"),
}

# Urutan Cutscene 1 (1a-1f) dan Dialog Pembuka sesuai naskah.
const DEFAULT_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"mode": "cutscene",
		"bg": "1a",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "",
		"side": "none",
		"text": "Di dunia ini, sihir adalah segala sumber kehidupan, para mahasihir sangat bergantung pada sihir.",
	},
	{
		"mode": "cutscene",
		"bg": "1b",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "",
		"side": "none",
		"text": "Namun, mahasihir (mahkluk asing sihir) mulai khawatir dengan sumber kekuatan sihir mereka mulai menipis.",
	},
	{
		"mode": "cutscene",
		"bg": "1c",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "",
		"side": "none",
		"text": "Salah satu kisah legenda mengatakan, ada satu dunia dimana para penghuninya dapat bertahan hidup tanpa menggunakan sihir.",
	},
	{
		"mode": "cutscene",
		"bg": "1d",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "",
		"side": "none",
		"text": "Para mahasihir mulai mencoba membuat portal untuk mengundang mahkluk yang dapat hidup tanpa sihir demi belajar bertahan hidup dari mereka.",
	},
	{
		"mode": "cutscene",
		"bg": "1d",
		"portal_visible": true,
		"animate_portal": true,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "",
		"side": "none",
		"text": "Akhirnya mereka berhasil mengundang salah satu mahkluk tersebut...",
	},
	{
		"mode": "cutscene",
		"bg": "1d",
		"portal_visible": true,
		"animate_portal": false,
		"spawn_visible": true,
		"animate_spawn": true,
		"transition_fade": false,
		"speaker": "",
		"side": "none",
		"text": "Uhh...",
	},
	{
		"mode": "dialogue",
		"bg": "aula_ritual",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": true,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "kaget",
		"alien_expression": "biasa",
		"text": "Weehh apa yang terjadi?! Dimana TV-ku?!",
	},
	{
		"mode": "dialogue",
		"bg": "aula_ritual",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "???",
		"side": "left",
		"expression": "kaget",
		"alien_expression": "biasa",
		"text": "Halo wahai mahkluk yang disebut dalam legenda, maaf telah mengundangmu secara mendadak.",
	},
	{
		"mode": "dialogue",
		"bg": "aula_ritual",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "???",
		"side": "left",
		"expression": "kaget",
		"alien_expression": "senang",
		"text": "Perkenalkan saya \\(•‿•)/. Kami hendak meminta tolong padamu. Kami mengalami keadaan yang sangat sulit, jadi kami ingin belajar bertahan hidup tanpa menggunakan sihir. Maukah kau mengajarkannya pada kami?",
	},
	{
		"mode": "dialogue",
		"bg": "aula_ritual",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "biasa",
		"text": "Tunggu sebentar, aku baru saja berganti baju dan mau menonton sinetron \"Cinta Trigonometri\" di TV-ku, aku belum sempat menyiapkan apapun.",
	},
	{
		"mode": "dialogue",
		"bg": "aula_ritual",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "\\(•‿•)/",
		"side": "left",
		"expression": "biasa",
		"alien_expression": "senang",
		"text": "Tak masalah, kurasa kita bisa menggunakan ruangan keramat yang terkunci setelah sekian lama.",
	},
	{
		"mode": "cutscene",
		"bg": "black",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": true,
		"speaker": "",
		"side": "none",
		"text": "Mereka pun berjalan meninggalkan aula ritual menuju ruangan keramat yang telah lama terkunci...",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": true,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "hehe",
		"alien_expression": "biasa",
		"text": "Ini gaada bedanya dengan rumah kakekku di kampung.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "\\(•‿•)/",
		"side": "left",
		"expression": "hehe",
		"alien_expression": "biasa",
		"text": "Ruangan ini digunakan milyaran tahun lalu oleh mahkluk yang hanya pernah kami dengar dalam kisah legenda turun temurun. Kami harap kau bisa menemukan apapun yang kau butuhkan disini.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "hehe",
		"alien_expression": "biasa",
		"text": "(Kalender di ujung ruangan menunjukkan tahun yang sama) Tahunnya sama, leluhur mereka nyulik manusia di masa depan apa begimana dah?",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "biasa",
		"text": "Baiklah kita mulai dari mana ya? Oh ya, siapa namamu tadi?",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "\\(•‿•)/",
		"side": "left",
		"expression": "biasa",
		"alien_expression": "tanya",
		"text": "\\(•‿•)/, kurasa aku penasaran apakah itu kulit aslimu? Terlihat unik sekali.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "tanya",
		"text": "Uhh. Kupanggil kau Rail saja. Ini bukan kulitku, ini pakaian. Fungsinya memang mirip seperti kulit, digunakan untuk melindungi tubuh dari panas dan dingin, bergaya dan kesenangan bahkan digunakan sebagai status sosial.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"expression": "biasa",
		"alien_expression": "senang",
		"text": "Oh benda yang menarik, bisa kau tunjukkan cara membuatnya?",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "hehe",
		"alien_expression": "biasa",
		"text": "Pertama-tama kita akan memerlukan kain, gunting dan alat untuk menjahit. Dan, uhh, kurasa tidak ada satupun benda itu disini.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"expression": "hehe",
		"alien_expression": "tanya",
		"text": "Bagaimana dengan benda-benda ini, apa ada yang kau cari disini?",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"portal_visible": false,
		"animate_portal": false,
		"spawn_visible": false,
		"animate_spawn": false,
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "senang",
		"text": "Ini bahan-bahan dasar semua. Yaampun, kurasa kita harus membuatnya dari nol. Untungnya banyak peralatan bengkel disini. Baiklah ayo kita buat alat dan bahan yang diperlukan.",
	},
]

# Alur setelah item Baju didapat: splash art baju -> dialog pra-negosiasi -> panel PENAWARAN.
const POST_BAJU_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"mode": "showcase",
		"bg": "percakapan",
		"transition_fade": true,
		"speaker": "Rail",
		"side": "center",
		"alien_expression": "baju",
		"text": "Wahh, ini terlihat indah. Sekarang aku mengerti kenapa bangsa kalian menyukai benda ini.",
	},
	{
		"mode": "showcase",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "center",
		"alien_expression": "baju",
		"text": "(Ternyata mereka bisa mengenakannya, nyangka ga lu pada)",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"alien_expression": "baju",
		"text": "Benda ini sangat bagus, bagaimana aku bisa membalas untuk baju ini?",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "left",
		"alien_expression": "baju",
		"text": "Kau tak perlu melakukannya. Ini hadiah karena kau berhasil membuatnya.",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"alien_expression": "baju",
		"text": "Tidak bisa begitu, kebaikan harus dibalas dengan kebaikan. Aku akan menawarkan benda berharga yang biasa kami gunakan sebagai alat tukar kebaikan.",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "left",
		"alien_expression": "baju",
		"text": "Ternyata disini ada sistem barter juga.",
	},
	{
		"mode": "negotiation",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "",
		"side": "left",
		"alien_expression": "baju",
		"text": "Atur jumlah Biji Iron di timbangan (5 seimbang, maks 10), lalu tekan Ajukan.",
	},
]

# Pengantar Stage 2 (Cermin) sesuai naskah baris 111-123.
const STAGE2_INTRO_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": true,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "baju",
		"text": "Kau bisa coba berkaca untuk melihat penampilanmu sendiri. Tunggu, kurasa disini tak ada cermin.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"expression": "biasa",
		"alien_expression": "tanya",
		"text": "Apa itu cermin? Apakah itu benda tanpa sihir lainnya?",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "tanya",
		"text": "Ya, tapi benda itu sering dikira memiliki sihir saking menakjubkannya. Bagaimana kalau sekarang kita membuat cermin? Aku akan menuliskan apa saja yang harus dilakukan di buku panduan.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "biasa",
		"text": "Kau bisa membuatnya dengan tata cara yang sama seperti yang kuajarkan tadi, tapi ingat! Kau harus memperhatikan kotak objektif dan mencari panduan dari barang yang ingin kau buat. Jangan sampai salah ya! Bengkel ini bisa meledak!",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"expression": "biasa",
		"alien_expression": "kaget",
		"text": "Apa?! Meledak?!",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "melet",
		"alien_expression": "kaget",
		"text": "Hehe, aku hanya bercanda.",
	},
]

# Alur setelah item Cermin didapat: showcase Rail bercermin -> dialog cahaya -> negosiasi Stage 2.
const POST_CERMIN_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"mode": "showcase",
		"bg": "percakapan",
		"transition_fade": true,
		"speaker": "Rail",
		"side": "center",
		"alien_expression": "cermin",
		"text": "Ohh benda ini memantulkan bayanganku. Kurasa aku paham kenapa kalian kira benda ini memiliki sihir didalamnya.",
	},
	{
		"mode": "showcase",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "center",
		"alien_expression": "cermin",
		"text": "Kami menyebutnya pemantulan cahaya. Sederhananya, cahaya yang mengenai tubuh kita akan membentuk bayangan. Sinar dari bayangan kita bergerak menuju cermin, lalu cermin memantulkan lagi bayangan tersebut sehingga mata kita bisa melihatnya.",
	},
	{
		"mode": "showcase",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "center",
		"alien_expression": "cermin",
		"text": "Cara kerja yang menarik. Tak butuh sedikitpun sihir untuk menggunakan ini.",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "left",
		"alien_expression": "cermin",
		"text": "(Oh aku punya satu ide jahil, nguaheheh)",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"alien_expression": "cermin",
		"text": "Cermin ini sangat menakjubkan! Biarkan aku memberikan Biji Iron lagi sebagai balasan untuk cermin ini.",
	},
	{
		"mode": "negotiation",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "",
		"side": "left",
		"alien_expression": "cermin",
		"text": "Atur jumlah Biji Iron di timbangan (5 seimbang, maks 10), lalu tekan Ajukan.",
	},
]

# Pengantar Stage 3 (Lipstik) sesuai naskah baris 137-141.
const STAGE3_INTRO_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": true,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "baju",
		"text": "Aku terpikirkan sesuatu, kau ingat kataku sebelumnya soal manusia yang suka menghias diri mereka? Kali ini kita akan membuat benda yang dapat merubah penampilan dalam sekejap.",
	},
	{
		"mode": "dialogue",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"expression": "biasa",
		"alien_expression": "tanya",
		"text": "Sepertinya menarik, aku jadi tak sabar.",
	},
]

# Alur setelah item Lipstik didapat: 3 cutscene CG -> dialog pra-negosiasi -> negosiasi Stage 3.
const POST_LIPSTIK_DIALOGUE_LINES: Array[Dictionary] = [
	{
		"mode": "dialogue",
		"layout": "cg",
		"bg": "lipstik_1_cermin",
		"transition_fade": true,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "biasa",
		"alien_expression": "baju",
		"text": "Biasanya kami menggunakannya di bagian wajah-",
	},
	{
		"mode": "dialogue",
		"layout": "cg",
		"bg": "lipstik_2_mengecat",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "kaget",
		"alien_expression": "baju",
		"text": "Apa yang kau lakukan?!",
	},
	{
		"mode": "dialogue",
		"layout": "cg",
		"bg": "lipstik_3_menor",
		"transition_fade": false,
		"play_fanfare": true,
		"bgm": "showcase",
		"speaker": "Rail",
		"side": "left",
		"expression": "kaget",
		"alien_expression": "menor",
		"text": "Katamu ini bisa digunakan untuk menghias diri.",
	},
	{
		"mode": "dialogue",
		"layout": "cg",
		"bg": "lipstik_3_menor",
		"transition_fade": false,
		"bgm": "showcase",
		"speaker": "Ilmuan",
		"side": "right",
		"expression": "ketawa",
		"alien_expression": "menor",
		"text": "Iya sih, tapi ga gitu juga.",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": true,
		"speaker": "Rail",
		"side": "left",
		"alien_expression": "menor",
		"text": "Aku akan menunjukkannya pada teman-temanku yang lain.",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Ilmuan",
		"side": "left",
		"expression": "kaget",
		"alien_expression": "menor",
		"text": "Tolong siapapun hentikan dia!!!",
	},
	{
		"mode": "dialogue",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "Rail",
		"side": "left",
		"alien_expression": "menor",
		"text": "Sebelum aku pergi memamerkannya, terimalah Biji Iron sebagai balasan untuk lipstik yang luar biasa ini!",
	},
	{
		"mode": "negotiation",
		"layout": "left_only",
		"bg": "percakapan",
		"transition_fade": false,
		"speaker": "",
		"side": "left",
		"alien_expression": "menor",
		"text": "Atur jumlah Biji Iron di timbangan (5 seimbang, maks 10), lalu tekan Ajukan.",
	},
]

@onready var background_texture: TextureRect = %BackgroundTexture
@onready var portal_overlay: TextureRect = %PortalOverlay
@onready var spawn_overlay: TextureRect = %SpawnOverlay
@onready var showcase_layer: Control = %ShowcaseLayer
@onready var showcase_burst: Control = %ShowcaseBurst
@onready var showcase_alien_sprite: TextureRect = %ShowcaseAlienSprite
@onready var characters_layer: Control = %CharactersLayer
@onready var black_screen_rect: ColorRect = %BlackScreenRect
@onready var transition_flash_rect: ColorRect = %TransitionFlashRect
@onready var alien_sprite: TextureRect = %AlienSprite
@onready var player_sprite: TextureRect = %PlayerSprite
@onready var negotiation_panel: Control = %NegotiationPanel
@onready var scale_beam: TextureRect = %ScaleBeam
@onready var left_pan_group: Control = %LeftPanGroup
@onready var right_pan_group: Control = %RightPanGroup
@onready var iron_items_container: Control = %IronItemsContainer
@onready var iron_pan_button: Button = %IronPanButton
@onready var balance_pointer: Control = %BalancePointer
@onready var minus_iron_button: Button = %MinusIronButton
@onready var iron_offer_label: Label = %IronOfferLabel
@onready var plus_iron_button: Button = %PlusIronButton
@onready var batalkan_button: Button = %BatalkanButton
@onready var ajukan_button: Button = %AjukanButton
@onready var disepakati_stamp: TextureRect = %DisepakatiStamp
@onready var lives_label: Label = %LivesLabel
@onready var negotiation_result_overlay: Control = %NegotiationResultOverlay
@onready var result_board: Control = %ResultBoard
@onready var result_star_1: ResultStarIcon = %ResultStar1
@onready var result_star_2: ResultStarIcon = %ResultStar2
@onready var result_star_3: ResultStarIcon = %ResultStar3
@onready var result_status_label: Label = %ResultStatusLabel
@onready var result_ulangi_button: Button = %ResultUlangiButton
@onready var result_lanjut_button: Button = %ResultLanjutButton
@onready var result_pengaturan_button: Button = %ResultPengaturanButton
@onready var result_menu_button: Button = %ResultMenuButton
@onready var dialogue_box_panel: PanelContainer = %DialogueBoxPanel
@onready var speaker_name_label: Label = %SpeakerNameLabel
@onready var dialogue_text_label: Label = %DialogueTextLabel
@onready var progress_label: Label = %ProgressLabel
@onready var continue_hint_label: Label = %ContinueHintLabel
@onready var skip_reserve_spacer: Control = %SkipReserveSpacer
@onready var cutscene_subtitle_panel: Control = %CutsceneSubtitlePanel
@onready var cutscene_subtitle_label: Label = %CutsceneSubtitleLabel
@onready var skip_button: Button = %SkipButton
@onready var help_button: Button = %HelpButton
@onready var help_popup: Control = %HelpPopup
@onready var close_help_button: Button = %CloseHelpButton

var _lines: Array[Dictionary] = []
var _current_index: int = 0
var _visible_float: float = 0.0
var _is_typing: bool = false
var _active_text_label: Label = null
var _cutscene_tween: Tween = null
var _fade_tween: Tween = null
var _layout_tween: Tween = null
var _scale_tween: Tween = null
var _stamp_tween: Tween = null
var _result_delay_tween: Tween = null
var _star_sfx_tween: Tween = null
var _shake_tween: Tween = null

var _current_mode: String = ""
var _is_post_baju_sequence: bool = false
var _active_stage: int = 1
var _current_speaker: String = ""
var _current_expression: String = ""
var _last_blip_char_index: int = 0
var _blip_cooldown: float = 0.0
var _iron_offer_count: int = INITIAL_IRON_OFFER
var _overpriced_threshold: int = 7
var _negotiation_lives: int = MAX_NEGOTIATION_LIVES
var _earned_stars: int = 3
var _is_deal_submitted: bool = false
var _is_negotiation_failed: bool = false
var _iron_pile_nodes: Array[TextureRect] = []


func _ready() -> void:
	portal_overlay.texture = PORTAL_TEXTURE
	spawn_overlay.texture = ILMUAN_SPAWN_TEXTURE
	alien_sprite.texture = ALIEN_EXPRESSIONS["biasa"]
	_active_text_label = dialogue_text_label

	_build_iron_pile_nodes()

	skip_button.pressed.connect(advance_or_skip)
	help_button.pressed.connect(open_help_popup)
	close_help_button.pressed.connect(close_help_popup)
	help_popup.gui_input.connect(_on_help_popup_gui_input)
	dialogue_box_panel.gui_input.connect(_on_dialogue_box_gui_input)
	gui_input.connect(_on_root_gui_input)

	minus_iron_button.pressed.connect(_on_minus_iron_pressed)
	plus_iron_button.pressed.connect(_on_plus_iron_pressed)
	iron_pan_button.pressed.connect(_on_iron_pan_pressed)
	batalkan_button.pressed.connect(reset_negotiation_offer)
	ajukan_button.pressed.connect(submit_negotiation_offer)

	result_ulangi_button.pressed.connect(replay_negotiation)
	result_lanjut_button.pressed.connect(_on_result_lanjut_pressed)
	result_pengaturan_button.pressed.connect(_on_result_pengaturan_pressed)
	result_menu_button.pressed.connect(_on_result_menu_pressed)

	if _lines.is_empty():
		set_dialogue_lines(DEFAULT_DIALOGUE_LINES)
	else:
		_show_line(0)


func _process(delta: float) -> void:
	_blip_cooldown = maxf(0.0, _blip_cooldown - delta)
	if not _is_typing or _active_text_label == null:
		return

	var total_chars := _active_text_label.get_total_character_count()
	_visible_float += TYPEWRITER_CHARS_PER_SEC * delta
	var visible_count := mini(int(_visible_float), total_chars)
	_active_text_label.visible_characters = visible_count

	if visible_count > _last_blip_char_index:
		var line_str := _active_text_label.text
		var has_spoken_char := false
		for char_idx in range(_last_blip_char_index, mini(visible_count, line_str.length())):
			var ch := line_str[char_idx]
			if not ch in [" ", "\n", "\t", ".", ",", "!", "?", ":", ";", "-", "\"", "'", "(", ")"]:
				has_spoken_char = true
				break
		if has_spoken_char and _blip_cooldown <= 0.0:
			AudioManager.play_voice_blip(_current_speaker, _current_expression)
			_blip_cooldown = 0.062
		_last_blip_char_index = visible_count

	if visible_count >= total_chars:
		_finish_typewriter()


func _unhandled_input(event: InputEvent) -> void:
	if help_popup.visible:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			close_help_popup()
			get_viewport().set_input_as_handled()
		return

	var focused := get_viewport().gui_get_focus_owner()
	if focused is Button:
		return

	if event.is_action_pressed("ui_accept") and not event.is_echo():
		advance_or_skip()
		get_viewport().set_input_as_handled()


func set_dialogue_lines(lines: Array[Dictionary]) -> void:
	_stop_result_delay_tween()
	AudioManager.stop_voice_burst()
	negotiation_result_overlay.visible = false
	_lines = lines.duplicate(true)
	if lines == DEFAULT_DIALOGUE_LINES:
		_is_post_baju_sequence = false
		_active_stage = 1
	_current_index = 0
	_current_mode = ""
	if is_node_ready():
		_show_line(0)


func start_post_baju_sequence() -> void:
	_is_post_baju_sequence = true
	_active_stage = 1
	set_dialogue_lines(POST_BAJU_DIALOGUE_LINES)


func start_stage2_intro_sequence() -> void:
	_is_post_baju_sequence = false
	_active_stage = 2
	set_dialogue_lines(STAGE2_INTRO_DIALOGUE_LINES)


func start_post_cermin_sequence() -> void:
	_is_post_baju_sequence = true
	_active_stage = 2
	set_dialogue_lines(POST_CERMIN_DIALOGUE_LINES)


func start_stage3_intro_sequence() -> void:
	_is_post_baju_sequence = false
	_active_stage = 3
	set_dialogue_lines(STAGE3_INTRO_DIALOGUE_LINES)


func start_post_lipstik_sequence() -> void:
	_is_post_baju_sequence = true
	_active_stage = 3
	set_dialogue_lines(POST_LIPSTIK_DIALOGUE_LINES)


func skip_to_negotiation() -> void:
	if _lines.is_empty():
		return
	for i in range(_lines.size()):
		if String(_lines[i].get("mode", "dialogue")) == "negotiation":
			_show_line(i)
			_finish_typewriter()
			return


func advance_or_skip() -> void:
	if help_popup.visible or negotiation_result_overlay.visible:
		return

	if _lines.is_empty():
		crafting_requested.emit()
		return

	if _is_typing or _is_cutscene_animating():
		_finish_typewriter()
		_finish_cutscene_animation()
		return

	if _is_current_mode_negotiation():
		ajukan_button.grab_focus()
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


func get_iron_offer_count() -> int:
	return _iron_offer_count


func get_overpriced_threshold() -> int:
	return _overpriced_threshold


func set_overpriced_threshold(threshold: int) -> void:
	_overpriced_threshold = clampi(threshold, RANDOM_OVERPRICED_MIN, RANDOM_OVERPRICED_MAX)


func get_negotiation_lives() -> int:
	return _negotiation_lives


func get_earned_stars() -> int:
	return _earned_stars


func is_deal_submitted() -> bool:
	return _is_deal_submitted


func is_negotiation_failed() -> bool:
	return _is_negotiation_failed


func open_help_popup() -> void:
	AudioManager.play_sfx(&"ui_click")
	help_popup.visible = true
	close_help_button.grab_focus()


func close_help_popup() -> void:
	AudioManager.play_sfx(&"ui_click")
	help_popup.visible = false
	if negotiation_result_overlay.visible:
		result_pengaturan_button.grab_focus()
	else:
		help_button.grab_focus()


func set_iron_offer_count(new_count: int, animate: bool = true) -> void:
	if _is_deal_submitted or _is_negotiation_failed:
		return
	var clamped := clampi(new_count, MIN_IRON_OFFER, MAX_IRON_OFFER)
	if clamped == _iron_offer_count and animate:
		return
	_iron_offer_count = clamped
	if animate:
		var pitch := 0.88 + 0.03 * float(clamped)
		AudioManager.play_sfx(&"ui_click", pitch, pitch + 0.02)
	_refresh_iron_offer_ui(animate)
	_update_negotiation_prompt_text()


func reset_negotiation_offer() -> void:
	AudioManager.play_sfx(&"ui_click")
	_stop_result_delay_tween()
	_iron_offer_count = INITIAL_IRON_OFFER
	_overpriced_threshold = randi_range(RANDOM_OVERPRICED_MIN, RANDOM_OVERPRICED_MAX)
	_negotiation_lives = MAX_NEGOTIATION_LIVES
	_earned_stars = 3
	_is_negotiation_failed = false
	_hide_disepakati_stamp()
	_set_negotiation_controls_enabled(true)
	_update_lives_ui()
	_refresh_iron_offer_ui(true)
	_set_system_dialogue_text("Penawaran direset. Atur kembali jumlah Biji Iron di timbangan.")


func submit_negotiation_offer() -> void:
	if _is_deal_submitted or _is_negotiation_failed:
		return

	if _iron_offer_count <= 0:
		AudioManager.play_sfx(&"craft_step_1", 0.70, 0.74)
		_set_system_dialogue_text("Tambahkan minimal 1 Biji Iron pada timbangan terlebih dahulu!")
		plus_iron_button.grab_focus()
		return

	var is_overpriced := (_iron_offer_count > TARGET_IRON_OFFER) and (_iron_offer_count >= _overpriced_threshold)
	if is_overpriced:
		AudioManager.play_sfx(&"craft_step_1", 0.70, 0.74)
		_negotiation_lives = maxi(_negotiation_lives - 1, 0)
		_update_lives_ui()

		if _negotiation_lives > 0:
			_play_negotiation_reject_shake()
			_set_character_dialogue_text("Rail", "Wah, %d Biji Iron kemahalan! Kurangi sedikit ya! (Sisa nyawa: %d)" % [_iron_offer_count, _negotiation_lives])
			minus_iron_button.grab_focus()
			return

		_is_negotiation_failed = true
		_earned_stars = 2
		_set_negotiation_controls_enabled(false)
		disepakati_stamp.texture = STAMP_GAGAL_TEX
		_show_disepakati_stamp()
		_set_character_dialogue_text("Rail", "Maaf, %d Biji Iron masih kemahalan dan nyawamu habis. Negosiasi gagal! (2 Bintang)" % _iron_offer_count)
		_schedule_result_tab(2, false)
		return

	_is_deal_submitted = true
	_earned_stars = 3
	_set_negotiation_controls_enabled(false)
	disepakati_stamp.texture = STAMP_DISEPAKATI_TEX
	_show_disepakati_stamp()
	AudioManager.play_sfx(&"fanfare")
	var item_label := "bajunya"
	if _active_stage == 3:
		item_label = "lipstiknya"
	elif _active_stage == 2:
		item_label = "cerminnya"
	_set_character_dialogue_text("Rail", "Sepakat! Ini %d Biji Iron sebagai balasan untuk %s! (3 Bintang)" % [_iron_offer_count, item_label])
	_schedule_result_tab(3, true)


func show_negotiation_result_tab(stars: int, _is_success: bool) -> void:
	_stop_result_delay_tween()
	_earned_stars = clampi(stars, 1, 3)

	showcase_layer.visible = false
	characters_layer.visible = false
	negotiation_panel.visible = false
	dialogue_box_panel.visible = false
	cutscene_subtitle_panel.visible = false
	skip_button.visible = false

	result_star_1.prepare_for_reveal(_earned_stars >= 1)
	result_star_2.prepare_for_reveal(_earned_stars >= 2)
	result_star_3.prepare_for_reveal(_earned_stars >= 3)

	if _active_stage == 3:
		result_status_label.text = "Semua Stage Selesai!"
		result_lanjut_button.text = "Selesai"
	else:
		result_status_label.text = "Stage Selesai"
		result_lanjut_button.text = "Lanjut"

	negotiation_result_overlay.visible = true
	result_board.pivot_offset = result_board.size * 0.5 if result_board.size != Vector2.ZERO else Vector2(270.0, 260.5)
	result_board.scale = Vector2(0.86, 0.86)
	result_board.modulate.a = 0.0

	var t := create_tween().set_parallel(true)
	t.tween_property(result_board, "scale", Vector2.ONE, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(result_board, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	result_star_1.play_pop_in(0.22)
	result_star_2.play_pop_in(0.50)
	result_star_3.play_pop_in(0.78)
	_schedule_star_sfx(_earned_stars)
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null:
		focus_owner.release_focus()


func replay_negotiation() -> void:
	AudioManager.play_sfx(&"ui_click")
	_stop_result_delay_tween()
	negotiation_result_overlay.visible = false
	skip_button.visible = true
	_current_mode = ""
	skip_to_negotiation()


func _show_line(index: int) -> void:
	if _lines.is_empty():
		return

	_stop_result_delay_tween()
	AudioManager.stop_voice_burst()
	negotiation_result_overlay.visible = false
	skip_button.visible = true

	_current_index = clampi(index, 0, _lines.size() - 1)
	var entry: Dictionary = _lines[_current_index]

	var prev_mode := _current_mode
	var mode := String(entry.get("mode", "dialogue"))
	_current_mode = mode
	var layout_mode := String(entry.get("layout", "both"))
	var is_cutscene := (mode == "cutscene")
	var is_showcase := (mode == "showcase")
	var is_negotiation := (mode == "negotiation")
	var bg_key := String(entry.get("bg", "percakapan"))
	var is_black_bg := (bg_key == "black")

	var custom_bgm := String(entry.get("bgm", ""))
	if not custom_bgm.is_empty():
		AudioManager.play_bgm(StringName(custom_bgm))
	elif is_cutscene:
		if not is_black_bg:
			AudioManager.play_bgm(&"cutscene")
	elif is_negotiation:
		AudioManager.play_bgm(&"negotiation")
	elif is_showcase:
		AudioManager.play_bgm(&"showcase")
		if prev_mode != "showcase":
			AudioManager.play_sfx(&"fanfare")
	elif layout_mode == "cg":
		AudioManager.play_bgm(&"dialogue")
	else:
		AudioManager.play_bgm(&"showcase" if _is_post_baju_sequence else &"dialogue")

	if bool(entry.get("play_fanfare", false)):
		AudioManager.play_sfx(&"fanfare")

	black_screen_rect.visible = is_black_bg
	if not is_black_bg:
		var bg_tex := BACKGROUNDS.get(bg_key, BACKGROUNDS["percakapan"]) as Texture2D
		if bg_tex != null:
			background_texture.texture = bg_tex

	_play_room_transition_if_needed(bool(entry.get("transition_fade", false)))

	showcase_layer.visible = is_showcase
	characters_layer.visible = (not is_cutscene) and (not is_showcase) and (layout_mode != "cg")
	negotiation_panel.visible = is_negotiation
	dialogue_box_panel.visible = not is_cutscene
	cutscene_subtitle_panel.visible = is_cutscene

	_apply_cutscene_overlays(entry)
	_apply_layout_for_mode(is_cutscene, is_showcase, is_negotiation, layout_mode, prev_mode)

	if is_negotiation:
		_enter_negotiation_mode()

	var speaker_text := String(entry.get("speaker", ""))
	speaker_name_label.text = speaker_text
	speaker_name_label.visible = (not is_cutscene) and (not speaker_text.is_empty())

	var line_text := String(entry.get("text", ""))
	dialogue_text_label.text = line_text
	cutscene_subtitle_label.text = line_text
	_active_text_label = cutscene_subtitle_label if is_cutscene else dialogue_text_label
	_active_text_label.visible_characters = 0
	_visible_float = 0.0
	_last_blip_char_index = 0
	_blip_cooldown = 0.0
	_is_typing = _active_text_label.get_total_character_count() > 0

	var expr_key := String(entry.get("expression", "biasa"))
	var expr_tex := PLAYER_EXPRESSIONS.get(expr_key, PLAYER_EXPRESSIONS["biasa"]) as Texture2D
	if expr_tex != null:
		player_sprite.texture = expr_tex

	var alien_expr_key := String(entry.get("alien_expression", "biasa"))
	var alien_tex := ALIEN_EXPRESSIONS.get(alien_expr_key, ALIEN_EXPRESSIONS["biasa"]) as Texture2D
	if alien_tex != null:
		alien_sprite.texture = alien_tex
		if is_showcase:
			showcase_alien_sprite.texture = alien_tex

	var side := String(entry.get("side", "right"))
	_current_speaker = speaker_text
	_current_expression = alien_expr_key if side != "right" else expr_key
	_highlight_active_speaker(side)

	progress_label.text = "%d / %d" % [_current_index + 1, _lines.size()]
	_update_hint_text()


func _stop_layout_tween() -> void:
	if _layout_tween != null and _layout_tween.is_valid():
		_layout_tween.kill()
	_layout_tween = null


func _apply_layout_for_mode(
	is_cutscene: bool,
	is_showcase: bool,
	is_negotiation: bool,
	layout_mode: String,
	prev_mode: String
) -> void:
	_stop_layout_tween()

	if is_negotiation:
		player_sprite.visible = false
		alien_sprite.position = Vector2(-64.0, 26.0)
		skip_reserve_spacer.visible = true

		dialogue_box_panel.anchor_left = 0.0
		dialogue_box_panel.anchor_right = 0.0
		dialogue_box_panel.anchor_top = 1.0
		dialogue_box_panel.anchor_bottom = 1.0
		dialogue_box_panel.offset_top = -196.0
		dialogue_box_panel.offset_bottom = -24.0

		skip_button.anchor_left = 0.0
		skip_button.anchor_right = 0.0
		skip_button.anchor_top = 1.0
		skip_button.anchor_bottom = 1.0
		skip_button.offset_top = -78.0
		skip_button.offset_bottom = -36.0

		if prev_mode != "negotiation":
			# Start wide at full dialogue width and off-screen right, then shrink & slide in cleanly.
			dialogue_box_panel.offset_left = 24.0
			dialogue_box_panel.offset_right = 1256.0
			skip_button.offset_left = 1142.0
			skip_button.offset_right = 1238.0
			negotiation_panel.offset_left = 1310.0
			negotiation_panel.offset_right = 1830.0
			negotiation_panel.modulate.a = 0.0

			_layout_tween = create_tween().set_parallel(true)
			_layout_tween.tween_property(dialogue_box_panel, "offset_left", 56.0, 0.46).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(dialogue_box_panel, "offset_right", 616.0, 0.46).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(skip_button, "offset_left", 504.0, 0.46).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(skip_button, "offset_right", 600.0, 0.46).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(negotiation_panel, "offset_left", 668.0, 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(negotiation_panel, "offset_right", 1188.0, 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(negotiation_panel, "modulate:a", 1.0, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			dialogue_box_panel.offset_left = 56.0
			dialogue_box_panel.offset_right = 616.0
			skip_button.offset_left = 504.0
			skip_button.offset_right = 600.0
			negotiation_panel.offset_left = 668.0
			negotiation_panel.offset_right = 1188.0
			negotiation_panel.modulate.a = 1.0
	elif is_cutscene:
		player_sprite.visible = true
		alien_sprite.position = Vector2(-118.0, 26.0)
		negotiation_panel.modulate.a = 1.0
		skip_reserve_spacer.visible = false
		skip_button.anchor_left = 1.0
		skip_button.anchor_right = 1.0
		skip_button.anchor_top = 0.0
		skip_button.anchor_bottom = 0.0
		skip_button.offset_left = -196.0
		skip_button.offset_top = 20.0
		skip_button.offset_right = -90.0
		skip_button.offset_bottom = 66.0
	else:
		player_sprite.visible = (layout_mode != "left_only")
		negotiation_panel.offset_left = 668.0
		negotiation_panel.offset_right = 1188.0
		negotiation_panel.modulate.a = 1.0

		dialogue_box_panel.anchor_left = 0.0
		dialogue_box_panel.anchor_right = 0.0
		dialogue_box_panel.anchor_top = 1.0
		dialogue_box_panel.anchor_bottom = 1.0
		dialogue_box_panel.offset_left = 24.0
		dialogue_box_panel.offset_top = -196.0
		dialogue_box_panel.offset_right = 1256.0
		dialogue_box_panel.offset_bottom = -24.0
		skip_reserve_spacer.visible = true
		skip_button.anchor_left = 0.0
		skip_button.anchor_right = 0.0
		skip_button.anchor_top = 1.0
		skip_button.anchor_bottom = 1.0
		skip_button.offset_left = 1142.0
		skip_button.offset_top = -78.0
		skip_button.offset_right = 1238.0
		skip_button.offset_bottom = -36.0

		if is_showcase and prev_mode != "showcase":
			showcase_burst.pivot_offset = Vector2(430.0, 430.0)
			showcase_burst.scale = Vector2(0.55, 0.55)
			showcase_burst.modulate.a = 0.0
			showcase_alien_sprite.pivot_offset = Vector2(340.0, 340.0)
			showcase_alien_sprite.scale = Vector2(0.88, 0.88)
			showcase_alien_sprite.modulate.a = 0.0

			_layout_tween = create_tween().set_parallel(true)
			_layout_tween.tween_property(showcase_burst, "scale", Vector2.ONE, 0.50).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(showcase_burst, "modulate:a", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(showcase_alien_sprite, "scale", Vector2.ONE, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_layout_tween.tween_property(showcase_alien_sprite, "modulate:a", 1.0, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		elif (not is_showcase) and layout_mode == "left_only" and prev_mode == "showcase":
			# Slide Rail from centered showcase coordinates to the left pre-negotiation position.
			alien_sprite.position = Vector2(300.0, 26.0)
			_layout_tween = create_tween()
			_layout_tween.tween_property(alien_sprite, "position", Vector2(-64.0, 26.0), 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		else:
			showcase_burst.scale = Vector2.ONE
			showcase_burst.modulate.a = 1.0
			showcase_alien_sprite.scale = Vector2.ONE
			showcase_alien_sprite.modulate.a = 1.0
			alien_sprite.position = Vector2(-64.0, 26.0) if layout_mode == "left_only" else Vector2(-118.0, 26.0)


func _enter_negotiation_mode() -> void:
	_stop_result_delay_tween()
	var left_item_tex := left_pan_group.get_node_or_null("BajuItemTexture") as TextureRect
	if left_item_tex != null:
		if _active_stage == 3:
			left_item_tex.texture = LIPSTIK_ITEM_TEXTURE
			left_item_tex.tooltip_text = "Lipstik (1 item yang ditawarkan)"
		elif _active_stage == 2:
			left_item_tex.texture = CERMIN_ITEM_TEXTURE
			left_item_tex.tooltip_text = "Cermin (1 item yang ditawarkan)"
		else:
			left_item_tex.texture = BAJU_ITEM_TEXTURE
			left_item_tex.tooltip_text = "Baju (1 item yang ditawarkan)"
	_iron_offer_count = INITIAL_IRON_OFFER
	_overpriced_threshold = randi_range(RANDOM_OVERPRICED_MIN, RANDOM_OVERPRICED_MAX)
	_negotiation_lives = MAX_NEGOTIATION_LIVES
	_earned_stars = 3
	_is_negotiation_failed = false
	_hide_disepakati_stamp()
	_set_negotiation_controls_enabled(true)
	_update_lives_ui()
	_refresh_iron_offer_ui(false)
	plus_iron_button.call_deferred("grab_focus")


func _set_negotiation_controls_enabled(enabled: bool) -> void:
	iron_pan_button.disabled = not enabled
	batalkan_button.disabled = not enabled
	ajukan_button.disabled = not enabled
	if enabled:
		minus_iron_button.disabled = (_iron_offer_count <= MIN_IRON_OFFER)
		plus_iron_button.disabled = (_iron_offer_count >= MAX_IRON_OFFER)
	else:
		minus_iron_button.disabled = true
		plus_iron_button.disabled = true


func _update_lives_ui() -> void:
	lives_label.text = "Nyawa: %d / %d" % [_negotiation_lives, MAX_NEGOTIATION_LIVES]
	if _negotiation_lives <= 1:
		lives_label.add_theme_color_override("font_color", Color("#9E1C1C"))
	else:
		lives_label.add_theme_color_override("font_color", Color("#1D130B"))


func _schedule_result_tab(stars: int, is_success: bool) -> void:
	_stop_result_delay_tween()
	_result_delay_tween = create_tween()
	_result_delay_tween.tween_interval(0.95)
	_result_delay_tween.tween_callback(func() -> void: show_negotiation_result_tab(stars, is_success))


func _stop_result_delay_tween() -> void:
	if _result_delay_tween != null and _result_delay_tween.is_valid():
		_result_delay_tween.kill()
	_result_delay_tween = null
	if _star_sfx_tween != null and _star_sfx_tween.is_valid():
		_star_sfx_tween.kill()
	_star_sfx_tween = null


func _schedule_star_sfx(stars: int) -> void:
	var star_keys: Array[StringName] = [&"craft_step_1", &"craft_step_2", &"craft_step_3"]
	var star_delays: Array[float] = [0.22, 0.28, 0.28]
	_star_sfx_tween = create_tween()
	for i in range(mini(stars, star_keys.size())):
		var key := star_keys[i]
		_star_sfx_tween.tween_interval(star_delays[i])
		_star_sfx_tween.tween_callback(func() -> void:
			AudioManager.play_sfx(key)
		)


func _play_negotiation_reject_shake() -> void:
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	var base_left := 668.0
	var base_right := 1188.0
	negotiation_panel.offset_left = base_left
	negotiation_panel.offset_right = base_right
	_shake_tween = create_tween()
	for offset_dx in [9.0, -9.0, 5.0, -5.0, 0.0]:
		_shake_tween.tween_property(negotiation_panel, "offset_left", base_left + offset_dx, 0.045)
		_shake_tween.parallel().tween_property(negotiation_panel, "offset_right", base_right + offset_dx, 0.045)


func _build_iron_pile_nodes() -> void:
	for child in iron_items_container.get_children():
		child.queue_free()
	_iron_pile_nodes.clear()

	for slot in IRON_PILE_LAYOUT:
		var item := TextureRect.new()
		item.texture = IRON_ORE_TEXTURE
		item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.position = slot["pos"]
		item.size = slot["size"]
		item.visible = false
		iron_items_container.add_child(item)
		_iron_pile_nodes.append(item)


func _refresh_iron_offer_ui(animate: bool) -> void:
	iron_offer_label.text = "Biji Iron: %d" % _iron_offer_count
	minus_iron_button.disabled = (_iron_offer_count <= MIN_IRON_OFFER)
	plus_iron_button.disabled = (_iron_offer_count >= MAX_IRON_OFFER)

	for i in range(_iron_pile_nodes.size()):
		_iron_pile_nodes[i].visible = (i < _iron_offer_count)

	var diff := clampf(float(_iron_offer_count - TARGET_IRON_OFFER), -5.0, 5.0)
	var target_angle_deg := diff * 2.8
	var rad := deg_to_rad(target_angle_deg)

	# Keep hanging pans vertical while following the rotated beam tips around SCALE_PIVOT.
	var left_pan_target := _compute_hook_displacement(LEFT_HOOK_OFFSET, rad)
	var right_pan_target := RIGHT_PAN_BASE_POS + _compute_hook_displacement(RIGHT_HOOK_OFFSET, rad)

	var normalized_t := (diff + 5.0) / 10.0
	var pointer_target_x := lerpf(24.0, BALANCE_TRACK_WIDTH - 24.0, normalized_t) - (POINTER_WIDTH * 0.5)

	if _scale_tween != null and _scale_tween.is_valid():
		_scale_tween.kill()
		_scale_tween = null

	if not animate:
		scale_beam.rotation_degrees = target_angle_deg
		left_pan_group.position = left_pan_target
		right_pan_group.position = right_pan_target
		balance_pointer.position.x = pointer_target_x
		return

	_scale_tween = create_tween().set_parallel(true)
	_scale_tween.tween_property(scale_beam, "rotation_degrees", target_angle_deg, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(left_pan_group, "position", left_pan_target, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(right_pan_group, "position", right_pan_target, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(balance_pointer, "position:x", pointer_target_x, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _compute_hook_displacement(rest_offset: Vector2, rad: float) -> Vector2:
	var cos_r := cos(rad)
	var sin_r := sin(rad)
	var rotated := Vector2(
		rest_offset.x * cos_r - rest_offset.y * sin_r,
		rest_offset.x * sin_r + rest_offset.y * cos_r
	)
	return rotated - rest_offset


func _update_negotiation_prompt_text() -> void:
	if not _is_current_mode_negotiation():
		return
	if _iron_offer_count == TARGET_IRON_OFFER:
		_set_system_dialogue_text("Penawaran: %d Biji Iron (pas di tengah bar). Tekan Ajukan untuk menyepakati." % _iron_offer_count)
	elif _iron_offer_count > TARGET_IRON_OFFER:
		_set_system_dialogue_text("Penawaran: %d Biji Iron (melewati tengah bar, berisiko kemahalan). Sisa nyawa: %d/%d." % [_iron_offer_count, _negotiation_lives, MAX_NEGOTIATION_LIVES])
	elif _iron_offer_count == 0:
		_set_system_dialogue_text("Piringan Biji Iron masih kosong. Tekan '+' atau klik piringan kanan untuk menambah Biji Iron.")
	else:
		_set_system_dialogue_text("Penawaran: %d Biji Iron. Tambah hingga tengah bar atau tekan Ajukan." % _iron_offer_count)


func _set_system_dialogue_text(new_text: String) -> void:
	speaker_name_label.text = ""
	speaker_name_label.visible = false
	_set_dialogue_text_immediate(new_text)


func _set_character_dialogue_text(speaker_name: String, new_text: String) -> void:
	speaker_name_label.text = speaker_name
	speaker_name_label.visible = not speaker_name.is_empty()
	_set_dialogue_text_immediate(new_text)
	AudioManager.play_voice_burst(speaker_name, 5)


func _set_dialogue_text_immediate(new_text: String) -> void:
	_is_typing = false
	dialogue_text_label.text = new_text
	dialogue_text_label.visible_characters = -1
	_update_hint_text()


func _show_disepakati_stamp() -> void:
	if _stamp_tween != null and _stamp_tween.is_valid():
		_stamp_tween.kill()
		_stamp_tween = null

	disepakati_stamp.visible = true
	disepakati_stamp.scale = Vector2(1.65, 1.65)
	disepakati_stamp.rotation_degrees = -12.0
	disepakati_stamp.modulate = Color(1.0, 1.0, 1.0, 0.0)

	_stamp_tween = create_tween().set_parallel(true)
	_stamp_tween.tween_property(disepakati_stamp, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_stamp_tween.tween_property(disepakati_stamp, "rotation_degrees", 0.0, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_stamp_tween.tween_property(disepakati_stamp, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _hide_disepakati_stamp() -> void:
	_is_deal_submitted = false
	if _stamp_tween != null and _stamp_tween.is_valid():
		_stamp_tween.kill()
		_stamp_tween = null
	disepakati_stamp.visible = false
	disepakati_stamp.scale = Vector2.ONE
	disepakati_stamp.rotation_degrees = 0.0
	disepakati_stamp.modulate = Color.WHITE


func _is_current_mode_negotiation() -> bool:
	if _lines.is_empty() or _current_index < 0 or _current_index >= _lines.size():
		return false
	return String(_lines[_current_index].get("mode", "dialogue")) == "negotiation"


func _apply_cutscene_overlays(entry: Dictionary) -> void:
	_stop_cutscene_tween()
	portal_overlay.scale = Vector2.ONE
	portal_overlay.modulate = Color.WHITE
	spawn_overlay.position = Vector2.ZERO
	spawn_overlay.modulate = Color.WHITE

	portal_overlay.visible = bool(entry.get("portal_visible", false))
	spawn_overlay.visible = bool(entry.get("spawn_visible", false))

	if portal_overlay.visible and bool(entry.get("animate_portal", false)):
		AudioManager.play_sfx(&"preview_match", 0.85, 0.92)
		portal_overlay.pivot_offset = portal_overlay.size * 0.5 if portal_overlay.size != Vector2.ZERO else Vector2(640.0, 360.0)
		portal_overlay.modulate.a = 0.0
		portal_overlay.scale = Vector2(0.88, 0.25)
		_cutscene_tween = create_tween().set_parallel(true)
		_cutscene_tween.tween_property(portal_overlay, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_cutscene_tween.tween_property(portal_overlay, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_cutscene_tween.finished.connect(_on_cutscene_tween_finished)
	elif spawn_overlay.visible and bool(entry.get("animate_spawn", false)):
		AudioManager.play_spawn_confused_sfx()
		spawn_overlay.modulate.a = 0.0
		spawn_overlay.position = Vector2(0.0, -180.0)
		_cutscene_tween = create_tween().set_parallel(true)
		_cutscene_tween.tween_property(spawn_overlay, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_cutscene_tween.tween_property(spawn_overlay, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_cutscene_tween.finished.connect(_on_cutscene_tween_finished)


func _play_room_transition_if_needed(should_fade: bool) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
		_fade_tween = null
	transition_flash_rect.color = Color(0.0, 0.0, 0.0, 0.0)

	if should_fade:
		transition_flash_rect.color = Color(0.0, 0.0, 0.0, 0.65)
		_fade_tween = create_tween()
		_fade_tween.tween_property(transition_flash_rect, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _is_cutscene_animating() -> bool:
	return _cutscene_tween != null and _cutscene_tween.is_running()


func _stop_cutscene_tween() -> void:
	if _cutscene_tween != null and _cutscene_tween.is_valid():
		_cutscene_tween.kill()
	_cutscene_tween = null


func _finish_cutscene_animation() -> void:
	_stop_cutscene_tween()
	portal_overlay.scale = Vector2.ONE
	portal_overlay.modulate = Color.WHITE
	spawn_overlay.position = Vector2.ZERO
	spawn_overlay.modulate = Color.WHITE
	_update_hint_text()


func _on_cutscene_tween_finished() -> void:
	_cutscene_tween = null
	_update_hint_text()


func _finish_typewriter() -> void:
	_is_typing = false
	if _active_text_label != null:
		_active_text_label.visible_characters = -1
	dialogue_text_label.visible_characters = -1
	cutscene_subtitle_label.visible_characters = -1
	_update_hint_text()


func _update_hint_text() -> void:
	if _is_typing or _is_cutscene_animating():
		continue_hint_label.text = "Klik / skip: selesaikan"
	elif _is_current_mode_negotiation():
		continue_hint_label.text = "Atur Biji Iron & Ajukan"
	elif _current_index >= _lines.size() - 1:
		continue_hint_label.text = "Klik / skip: mulai meracik"
	else:
		continue_hint_label.text = "Klik / skip: lanjut"


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


func _on_minus_iron_pressed() -> void:
	set_iron_offer_count(_iron_offer_count - 1, true)


func _on_plus_iron_pressed() -> void:
	set_iron_offer_count(_iron_offer_count + 1, true)


func _on_iron_pan_pressed() -> void:
	if _iron_offer_count < MAX_IRON_OFFER:
		set_iron_offer_count(_iron_offer_count + 1, true)
	else:
		_set_system_dialogue_text("Piringan sudah penuh (%d Biji Iron). Tekan '-' untuk mengurangi atau Ajukan sekarang." % MAX_IRON_OFFER)


func _on_result_lanjut_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	if _active_stage < 3:
		next_stage_requested.emit()
	else:
		main_menu_requested.emit()


func _on_result_pengaturan_pressed() -> void:
	open_help_popup()


func _on_result_menu_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	if main_menu_requested.get_connections().is_empty():
		set_dialogue_lines(DEFAULT_DIALOGUE_LINES)
	else:
		main_menu_requested.emit()


func _on_help_popup_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			close_help_popup()
			help_popup.accept_event()


func _on_dialogue_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			advance_or_skip()
			dialogue_box_panel.accept_event()


func _on_root_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			advance_or_skip()
			accept_event()
