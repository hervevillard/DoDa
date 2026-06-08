# DoDa — Claude Code Project Guide

## What is DoDa?
Bilingual kids learning app (English + Kinyarwanda) targeting Android/iOS tablets.
Built with Flutter, landscape-only, Material 3.

## Architecture
```
lib/
  core/            — providers & services (language, progress, audio, content)
  models/          — data classes (LetterModel, WordModel)
  screens/         — 6 screens (home, progress_map, letter_tracing, phonics, word_building, parent)
  widgets/         — reusable UI (mascot, tracing_canvas, reward_overlay, african_decoration)
  theme.dart       — all colours & typography (African palette)
assets/
  data/            — letters_en.json, letters_rw.json, words.json
  audio/           — placeholder .mp3 files (need recording)
  images/          — placeholder images (need artwork)
  fonts/           — Nunito (Regular / Bold / ExtraBold)
docs/              — design & planning documents
.claude/commands/  — project slash commands
```

## Key conventions
- All colours live in `lib/theme.dart` — use `kColor*` constants, never hard-code hex.
- African decoration widgets live in `lib/widgets/african_decoration.dart`.
- Every activity screen uses `ParchmentBackground` from `african_decoration.dart`.
- The progress map uses `AfricanBackground` (savanna gradient).
- Landscape only — always test in landscape viewport.
- State management: Provider only (no Riverpod, no Bloc).
- Audio files are optional — `DodaAudioPlayer` silently skips missing assets.

## Running the app
```bash
flutter pub get
flutter run -d <device>          # or use /run skill
```

## Tracing canvas notes
- Guide paths stored as SVG-subset strings in `assets/data/letters_en.json` (`stroke_paths` array).
- Coordinate space: 0–100 grid, scaled to canvas at paint time.
- Supported commands: M, L, Q (quadratic Bézier), C (cubic Bézier).
- One stroke per array item. Active stroke shown with pulsing start circle + numbered badge.
- Color picker lets the child pick a pen colour before tracing.
- Cursor overlay shows finger position with crosshair.
- Accuracy = fraction of guide points within 28px of user stroke.

## Asset placeholders
- Audio: empty .mp3 stubs — drop real recordings into `assets/audio/`.
- Images: `Icon(Icons.image_rounded)` shown until real PNGs added to `assets/images/words/`.
- Fonts: download Nunito from Google Fonts into `assets/fonts/`.

## Slash commands available
- `/run`   — start the app on a connected device
- `/check` — run `flutter analyze` and `flutter test`
- `/assets`— list all asset files and flag missing ones

## Parent PIN
Hard-coded to `1234`. Change in `lib/screens/parent_screen.dart`.
