# humantools

Game edukasi 2D berbasis cerita dengan sistem *crafting* (ala Minecraft) yang dibangun menggunakan **Godot 4.7** (renderer **GL Compatibility** untuk target ekspor **WebGL**).

## Struktur Direktori

```text
res://
├── addons/                     # Plugin editor (Godot AI & MCP Toolkit)
├── assets/                     # Aset mentah non-kode
│   ├── sprites/                # Sprite karakter, item, dan objek 2D
│   ├── backgrounds/            # Latar belakang / environment
│   ├── audio/
│   │   ├── music/              # BGM (.ogg)
│   │   └── sfx/                # Efek suara (.wav / .ogg)
│   └── fonts/                  # Font (.ttf / .otf)
├── scenes/                     # Semua scene Godot (.tscn)
│   ├── main/                   # Root scene (main.tscn & main.gd), entry point game
│   ├── dialogue/               # Visual Novel dialogue scene, UI, dan choice button
│   ├── crafting/               # Meja crafting top-down, card puzzle, dan assembly grid
│   ├── npc/                    # Portrait NPC
│   └── ui/                     # Inventory dan komponen UI bersama
├── scripts/                    # Script GDScript (.gd)
│   ├── managers/               # Manager / autoload global
│   ├── systems/                # Sistem gameplay (crafting, puzzle, cerita)
│   └── components/             # Komponen reusable
├── data/                       # Data game (.tres / .json / custom resource)
│   ├── blueprints/             # Data blueprint
│   ├── recipes/                # Data resep crafting
│   └── quests/                 # Data quest & cerita
├── project.godot               # Konfigurasi proyek Godot
└── icon.svg                    # Ikon proyek
```

## Konvensi Penamaan

- **Folder & file** (`.tscn`, `.gd`, `.tres`, aset): `snake_case` (contoh: `player_controller.gd`, `main_menu.tscn`).
- **Nama Node di Scene Tree**: `PascalCase` (contoh: `Player`, `AnimationPlayer`, `CollisionShape2D`).
- **Class name** (`class_name`): `PascalCase` (contoh: `class_name RecipeData`).

## Catatan Kolaborasi

- Folder kosong menggunakan `.gitkeep` agar struktur tetap sinkron di Git.
- Folder `.godot/` diabaikan oleh `.gitignore` dan akan di-generate otomatis oleh Godot saat proyek dibuka.
- Pastikan menggunakan renderer **GL Compatibility** (`gl_compatibility`) saat menguji atau mengekspor untuk **WebGL**.
