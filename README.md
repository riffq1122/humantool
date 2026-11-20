# humantools

Game edukasi 2D berbasis cerita dengan sistem *crafting* (ala Minecraft) yang dibangun menggunakan **Godot 4.7** (renderer **GL Compatibility** untuk target ekspor **WebGL**).

## Struktur Direktori

```text
res://
├── addons/                     # Plugin editor (Godot AI & MCP Toolkit)
├── assets/                     # Aset mentah non-kode
│   ├── art/
│   │   ├── characters/         # Sprite karakter & portrait dialog
│   │   ├── items/              # Ikon item & material crafting
│   │   ├── tiles/              # Tileset environment / workshop
│   │   └── ui/                 # Panel, slot inventory, tombol
│   ├── audio/
│   │   ├── music/              # BGM (.ogg)
│   │   └── sfx/                # Efek suara crafting, UI, langkah (.wav / .ogg)
│   ├── fonts/                  # Font (.ttf / .otf)
│   └── shaders/                # Shader 2D (.gdshader)
├── autoload/                   # Singleton global (Project Settings > Autoload)
├── resources/                  # Custom Resource (.gd & .tres) untuk data-driven design
│   ├── items/                  # Definisi & data item
│   ├── recipes/                # Definisi & data resep crafting
│   └── dialogues/              # Data dialog cerita & materi edukasi
├── scenes/                     # Scene (.tscn) & script (.gd) co-located per fitur
│   ├── main/                   # Root scene (main.tscn & main.gd) — entry point game
│   ├── world/                  # Area 2D / workshop / level eksplorasi
│   ├── entities/
│   │   ├── player/             # Scene & script player
│   │   └── npc/                # Scene & script NPC (pemberi cerita/quest)
│   ├── crafting/               # Meja crafting, grid slot, preview hasil & info edukasi
│   ├── inventory/              # UI inventory / hotbar & slot item
│   ├── dialogue/               # Dialogue box cerita & pilihan jawaban
│   └── ui/                     # Main menu, HUD, pause menu, buku resep
├── project.godot               # Konfigurasi proyek Godot
└── icon.svg                    # Ikon proyek
```

## Konvensi Penamaan

- **Folder & file** (`.tscn`, `.gd`, `.tres`, aset): `snake_case` (contoh: `player_controller.gd`, `main_menu.tscn`).
- **Nama Node di Scene Tree**: `PascalCase` (contoh: `Player`, `AnimationPlayer`, `CollisionShape2D`).
- **Class name** (`class_name`): `PascalCase` (contoh: `class_name ItemData`).

## Catatan Kolaborasi

- Folder kosong menggunakan `.gitkeep` agar struktur tetap sinkron di Git.
- Folder `.godot/` diabaikan oleh `.gitignore` dan akan di-generate otomatis oleh Godot saat proyek dibuka.
- Pastikan menggunakan renderer **GL Compatibility** (`gl_compatibility`) saat menguji atau mengekspor untuk **WebGL**.
