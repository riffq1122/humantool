# Handoff Guide — Melanjutkan Stage 3 (Lipstik) | Zero Magic Craft (`humantools`)

Dokumen ini berisi seluruh konteks teknis, status proyek, aset yang tersedia, naskah cerita, dan checklist implementasi agar AI berikutnya bisa langsung melanjutkan pengerjaan **Stage 3 (Pembuatan Lipstik)**.

---

## 1. Ringkasan Proyek & Status Terkini

- **Engine**: Godot `4.7.2-stable` (`GL Compatibility`), resolusi viewport `1280x720`, stretch mode `canvas_items` (`project.godot`).
- **Main Scene**: `res://scenes/main/main.tscn` (`scenes/main/main.gd`).
- **Autoload Singletons (`project.godot`)**:
  - `GameSettings` (`res://scripts/managers/game_settings.gd`) — menyimpan `music_volume`, `sfx_volume`, dan `fullscreen` ke `user://settings.cfg`.
  - `AudioManager` (`res://scripts/managers/audio_manager.gd`) — mengatur bus `Music` & `SFX` (`default_bus_layout.tres`), crossfade BGM looping (`BGM_BASE_DB = -14.0`), voice blip typewriter per karakter (`+2.0 dB` untuk Ilmuan & Rail, `-4.0 dB` untuk narasi), dan SFX kartu/UI/negosiasi.
- **Konsep Game**: Seorang Ilmuan manusia masuk melalui portal ke dunia Mahasihir dan mengajari alien bernama **Rail** cara membuat benda manusia tanpa sihir melalui gameplay **Card Crafting** dan **Barter/Negosiasi Timbangan**.

### Yang Sudah Selesai & Terverifikasi
1. **Beranda (`scenes/ui/main_menu.tscn` & `scenes/ui/main_menu.gd`)**:
   - Logo **ZERO MAGIC CRAFT** (`res://assets/ui/main_menu/logo_zero_magic_craft.png`), tombol `Mainkan`, `Pengaturan`, `Keluar` (sapuan highlight oranye hanya muncul saat hover atau navigasi keyboard), dan animasi idle kejar-kejaran Rail & Ilmuan.
   - Panel Pengaturan: slider `Musik`, slider `Efek suara`, toggle `Layar penuh`.
2. **Loading Screen (`scenes/ui/loading_screen.tscn` & `scenes/ui/loading_screen.gd`)**:
   - Threaded loading screen dengan animasi Rail berjalan di atas bar progres saat transisi antar scene besar.
3. **Sistem Audio (`scripts/managers/audio_manager.gd`)**:
   - BGM per bagian: `menu` (`3. Fun Time.ogg`), `cutscene` (`5. The Shepherd.ogg`), `dialogue` (`7. Riding Horse.ogg`), `crafting` (`4. Solve Puzzle.ogg`), `showcase` (`2. Green Field.ogg`), `negotiation` (`1. Playground.ogg`).
   - Catatan: File `res://assets/audio/music/6. Dancing Robot.ogg` belum dipakai dan bisa dimanfaatkan untuk Stage 3 jika diinginkan.
4. **Stage 1 — Pembuatan Baju (Dengan Tutorial Interaktif)**:
   - Cutscene pembuka `1a–1f` + dialog aula ritual & ruang kerja (`DEFAULT_DIALOGUE_LINES`).
   - Crafting tutorial terpandu (`TutorialPhase`): `alat_jahit`, `kain`, `gunting` -> `baju`.
   - Showcase Rail memakai baju (`rail muslimah.png`) + negosiasi timbangan (`Baju` vs `Biji Iron`) + papan hasil bintang.
5. **Stage 2 — Pembuatan Cermin (Tanpa Tutorial Overlay)**:
   - Transisi otomatis ketika klik `Lanjut` pada papan hasil Stage 1 (sinyal `next_stage_requested` dari `dialogue_scene.gd` ke `main.gd`), atau via tombol dev `Dev: Stage 2`.
   - Dialog pengantar Cermin (`STAGE2_INTRO_DIALOGUE_LINES`, naskah baris 111–123).
   - Crafting Stage 2 (`_stage_number == 2`) tanpa overlay/spotlight tutorial: `perak_batangan`, `kaca` -> `cermin`, dengan Buku Panduan Stage 2 dan popup kartu `Cermin` (`LevelSubtitleLabel` & `LevelCompleteQuoteLabel` dinamis per stage).
   - Showcase Rail bercermin (`rail_cermin.png`) + penjelasan pemantulan cahaya (`POST_CERMIN_DIALOGUE_LINES`) + negosiasi timbangan Stage 2 (`res://assets/items/cermin.png` di piringan kiri vs `Biji Iron` di piringan kanan).

---

## 2. Arsitektur File Utama untuk Stage 3

| File | Peran & Apa yang Perlu Diperluas untuk Stage 3 |
|---|---|
| `scenes/main/main.gd` | Mengelola `enum StoryStage` (`OPENING`, `POST_BAJU`, `STAGE2_INTRO`, `POST_CERMIN`). Tambahkan `STAGE3_INTRO` dan `POST_LIPSTIK`, tombol shortcut `Dev: Stage 3` di `_create_dev_jump_bar()`, routing di `show_dialogue_scene()`, `show_crafting_scene()` (`setup_stage(3)`), `_on_next_stage_requested()`, dan `_on_crafting_craft_completed()`. |
| `scenes/dialogue/dialogue_scene.gd` | Mengelola array dialog dan mode `cutscene` / `dialogue` / `showcase` / `negotiation`. `ALIEN_EXPRESSIONS` **sudah memiliki** `"menor": preload("res://assets/sprites/alien/rail menor.png")`. Saat ini `_on_result_lanjut_pressed()` pada akhir Stage 2 menampilkan `"Tahap Lipstik segera hadir!"` — ubah agar memancarkan `next_stage_requested` ke Stage 3 (gunakan `var _current_stage: int = 1` menggantikan atau melengkapi `_is_stage2_sequence`). |
| `scenes/crafting/crafting_scene.gd` | Mengelola meja kerja per stage melalui `setup_stage(stage_number: int)`. Tambahkan cabang `_stage_number == 3` untuk `STAGE3_OBJECTIVE_SEQUENCE`, `STAGE3_DECK_POOLS`, inventori awal Stage 3, halaman Buku Panduan Stage 3, auto-replenish bahan dasar Stage 3, teks popup `LevelCompletePopup` untuk `Lipstik`, dan tambahkan item Stage 3 ke `STORAGE_OUTPUT_IDS` serta resep baru ke `DEFAULT_RECIPES`. |
| `scenes/crafting/card_ui.gd` | `FINAL_ITEM_IDS` sudah berisi `[&"baju", &"cermin", &"lipstik"]` sehingga kartu `lipstik` otomatis tampil ungu berlabel `ITEM`. |

---

## 3. Naskah & Alur Stage 3 (Sesuai `naskah-singkat-opening-n-tutorial (1).md`)

Dari `naskah-singkat-opening-n-tutorial (1).md` baris 137–160:

### A. Dialog Pengantar Stage 3 (`STAGE3_INTRO_DIALOGUE_LINES`)
- **Ilmuan**: *"Aku terpikirkan sesuatu, kau ingat kataku sebelumnya soal manusia yang suka menghias diri mereka? Kali ini kita akan membuat benda yang dapat merubah penampilan dalam sekejap."*
- **Rail**: *"Sepertinya menarik, aku jadi tak sabar."*
- Lanjut ke **Crafting Stage 3** (tanpa dialog tutorial yang memblokir layar, sama seperti Stage 2).

### B. Crafting Stage 3 — Membuat Lipstik
- Pemain membaca kotak Objektif & Buku Panduan untuk meracik bahan setengah jadi hingga menjadi **Lipstik**.
- Setelah `lipstik` berhasil dibuat, tampilkan `LevelCompletePopup` dengan kartu `res://assets/card/Lipstik.png`.

### C. Showcase & Ending Stage 3 (`POST_LIPSTIK_DIALOGUE_LINES`)
1. **Ilmuan** (`expression: "biasa"`): *"Biasanya kami menggunakannya di bagian wajah-"*
2. **Ilmuan** (`expression: "kaget"`): *"Apa yang kau lakukan?!"*
3. **Showcase Rail Menor** (`mode: "showcase"`, `alien_expression: "menor"` -> `res://assets/sprites/alien/rail menor.png`):
   - **Rail**: *"Katamu ini bisa digunakan untuk menghias diri."*
4. **Ilmuan** (`expression: "ketawa"`): *"Iya sih, tapi ga gitu juga."*
5. **Rail** (`alien_expression: "menor"`): *"Aku akan menunjukkannya pada teman-temanku yang lain."*
6. **Ilmuan** (`expression: "kaget"`): *"Tolong siapapun hentikan dia!!!"*
7. Lanjut ke **Negosiasi Stage 3** (piringan kiri `res://assets/items/lipstik jadi.png` vs `Biji Iron` di piringan kanan) atau papan selesai game (sesuaikan atau konfirmasi ke user apakah Stage 3 juga diakhiri negosiasi seperti Stage 1 & 2, atau langsung tamat).

---

## 4. Aset Stage 3 yang Sudah Tersedia di Repository

### A. Resource Kartu yang Sudah Ada di `data/cards/` (sudah masuk `DEFAULT_CARDS` di `crafting_scene.gd`)
- `res://data/cards/lilin.tres` — `card_id = &"lilin"`, `display_name = "Lilin"`, Material (`consumable = true`)
- `res://data/cards/pewarna.tres` — `card_id = &"pewarna"`, `display_name = "Pewarna"`, Material (`consumable = true`)
- `res://data/cards/lipstik_batangan.tres` — `card_id = &"lipstik_batangan"`, `display_name = "Lipstik Batangan"`, Material (`consumable = true`)
- `res://data/cards/lipstik.tres` — `card_id = &"lipstik"`, `display_name = "Lipstik"`, Final Item (`consumable = false`)
- `res://data/cards/menumbuk.tres` — `card_id = &"menumbuk"`, `display_name = "Menumbuk"`, Process
- `res://data/cards/mortar.tres` — `card_id = &"mortar"`, `display_name = "Mortar"`, Tool
- `res://data/cards/peleburan.tres` — `card_id = &"peleburan"`, `display_name = "Melebur"`, Process
- `res://data/cards/tungku.tres` — `card_id = &"tungku"`, `display_name = "Tungku"`, Tool
- `res://data/cards/cetakan.tres` — `card_id = &"cetakan"`, `display_name = "Cetakan"`, Tool
- `res://data/cards/besi_batangan.tres`, `menempa.tres`, `palu.tres`

### B. Aset Gambar Terkait Stage 3 di `assets/`
- `res://assets/sprites/alien/rail menor.png` (Rail memakai lipstik belepotan — sudah dimuat di `ALIEN_EXPRESSIONS["menor"]`)
- `res://assets/card/Lipstik.png` & `res://assets/items/lipstik jadi.png`
- `res://assets/card/lipstik batangan.png` & `res://assets/items/lipstik setengah jadi.png`
- `res://assets/card/Lilin.png` & `res://assets/items/lilin lebah.png`
- `res://assets/card/Pewarna.png` & `res://assets/items/pewarna.png`
- `res://assets/card/menumbuk.png` & `res://assets/items/1 ber-tumbuk.png`
- `res://assets/card/Mortar.png` & `res://assets/items/mortar.png`
- `res://assets/items/mawardi.png` (ikon bunga mawar; catatan: belum ada `CardData` `.tres` khusus bunga maupun tekstur khusus di `assets/card/` selain `Group 32..38.png`, sementara `CardUI` sudah mendukung fallback ke `icon` atau pakai langsung kartu `pewarna` / buat `bunga.tres`)

### C. Resep yang Belum Dibuat di `data/recipes/`
Saat ini `data/recipes/` baru memiliki 7 resep (4 untuk Stage 1, 3 untuk Stage 2):
- `alat_jahit_recipe.tres`, `kain_recipe.tres`, `gunting_recipe.tres`, `baju_recipe.tres`
- `perak_batangan_recipe.tres`, `kaca_recipe.tres`, `cermin_recipe.tres`

**Resep untuk Stage 3 belum dibuat.** Semua resep menggunakan `RecipeData` (`scripts/systems/recipe_data.gd`):
```gdscript
recipe_id = &"..."
recipe_name = "..."
required_cards = Array[StringName]([&"card_1", &"card_2", &"card_3"]) # selalu tepat 3 kartu
allow_extra_cards = false
consume_process = false
consume_tools = Array[StringName]([])
outputs = Array[StringName]([&"output_card_id"])
```

Contoh rancangan 2 langkah menggunakan kartu yang sudah 100% tersedia di `data/cards/`:
1. `lipstik_batangan_recipe.tres`: `[&"lilin", &"pewarna", &"peleburan"]` (atau `tungku` / `cetakan`) -> `[&"lipstik_batangan"]`
2. `lipstik_recipe.tres`: `[&"lipstik_batangan", &"besi_batangan", &"cetakan"]` (atau `[&"lipstik_batangan", &"cetakan", &"palu"]` / kombinasi 3 kartu dengan `mortar`/`menumbuk`) -> `[&"lipstik"]`

> **Tips untuk AI berikutnya**: Sebelum menulis `.tres` resep Stage 3, tanyakan dulu ke user (atau cek konfirmasi):
> 1. Apakah ingin menambah kartu bahan mentah **Bunga** (`mawardi.png` -> `Pewarna` via `Menumbuk` + `Mortar`), atau langsung mulai dengan `Lilin` dan `Pewarna` yang `.tres`-nya sudah ada?
> 2. Bagaimana kombinasi 3 kartu untuk membuat `Lipstik Batangan` dan `Lipstik`?
> 3. Setelah showcase `rail menor.png` & dialog *"Tolong siapapun hentikan dia!!!"*, apakah Stage 3 ditutup dengan Negosiasi Barter dulu atau langsung layar Tamat / Credit?

---

## 5. Checklist Langkah Implementasi Stage 3

1. **Buat Resource Resep (`.tres`) di `data/recipes/`**:
   - Buat `lipstik_batangan_recipe.tres` dan `lipstik_recipe.tres` (serta `pewarna_recipe.tres` & `data/cards/bunga.tres` bila pakai bunga).
   - Daftarkan resep baru ke array `DEFAULT_RECIPES` di `scenes/crafting/crafting_scene.gd`.
2. **Perluas `scenes/crafting/crafting_scene.gd`**:
   - Tambahkan `&"pewarna"` (jika dibuat craftable), `&"lipstik_batangan"`, dan `&"lipstik"` ke `STORAGE_OUTPUT_IDS`.
   - Tambahkan `LIPSTIK_CARD_TEX := preload("res://assets/card/Lipstik.png")`, `STAGE3_OBJECTIVE_SEQUENCE`, dan `STAGE3_DECK_POOLS`.
   - Perbarui `setup_stage(stage_number)`, `_configure_stage_inventory_and_state()`, `_get_active_objective_sequence()`, `_get_active_deck_pools()`, starter auto-replenish, `_apply_tutorial_state()`, `_handle_tutorial_after_craft()`, `_refresh_objective_and_book()`, `craft_selected_cards()` (`out_id == &"lipstik"`), `_play_intermediate_craft_sfx()`, dan `show_level_complete_popup()`.
   - **Penting (Godot 4.7 GDScript)**: Jangan memakai ekspresi ternary `a if cond else b` untuk mengisi variabel/return bertipe `Array[StringName]`, karena ternary mengevaluasi hasil menjadi untyped `Array` dan memicu runtime debugger break. Gunakan percabangan `if/else` biasa.
3. **Perluas `scenes/dialogue/dialogue_scene.gd`**:
   - Tambahkan `LIPSTIK_ITEM_TEXTURE := preload("res://assets/items/lipstik jadi.png")`.
   - Ubah `_is_stage2_sequence: bool` menjadi `var _active_stage: int = 1` agar bersih untuk Stage 1, 2, dan 3.
   - Tambahkan `STAGE3_INTRO_DIALOGUE_LINES` dan `POST_LIPSTIK_DIALOGUE_LINES` beserta `start_stage3_intro_sequence()` dan `start_post_lipstik_sequence()`.
   - Update `_enter_negotiation_mode()`, `submit_negotiation_offer()`, dan `_on_result_lanjut_pressed()` (akhir Stage 2 memancarkan `next_stage_requested`, akhir Stage 3 menampilkan panel selesai / kembali ke menu utama).
4. **Perluas `scenes/main/main.gd`**:
   - Tambahkan `STAGE3_INTRO` dan `POST_LIPSTIK` pada `enum StoryStage`.
   - Hubungkan transisi Stage 2 -> Stage 3 di `_on_next_stage_requested()`, `show_dialogue_scene()`, `show_crafting_scene()` (`setup_stage(3)`), `_on_crafting_craft_completed()` (`result.output_ids.has(&"lipstik")`), serta tombol `Dev: Stage 3` di `_create_dev_jump_bar()`.
5. **Verifikasi di Godot MCP**:
   - Jalankan `filesystem_manage(op="scan")`, pastikan `logs_read(source="editor")` nol error.
   - Jalankan `project_run(mode="main")` dan uji alur lengkap `Lanjut` dari Stage 2 -> Dialog Pengantar Stage 3 -> Crafting Lipstik -> Showcase `rail menor.png` -> Negosiasi / Selesai, serta pastikan `logs_read(source="game")` bebas error/warning.
