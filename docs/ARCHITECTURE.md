# DoDa — Architecture

## Folder structure
```
lib/
  core/            — providers & services (language, progress, audio, content)
  models/          — data classes (LetterModel, WordModel)
  screens/         — home, progress_map, letter_tracing, phonics, word_building, parent, number_tracing
  widgets/         — mascot, tracing_canvas, reward_overlay, african_decoration, language_toggle, star_counter
  theme.dart       — all colours & typography (African palette)
assets/
  data/            — letters_en.json, letters_rw.json, words.json
  audio/           — placeholder .mp3/.wav stubs (need recording)
  images/          — placeholder images (need artwork)
  fonts/           — Nunito (Regular / Bold / ExtraBold)
docs/              — design & planning documents
.claude/commands/  — project slash commands (/run, /check, /assets)
```

## State management
Provider only — no Riverpod, no Bloc.

Key providers (all registered in `main.dart`):
| Provider | Purpose |
|---|---|
| `LanguageProvider` | Current language (EN/RW), persisted via shared_preferences |
| `ProgressManager` | Stars + completed levels, persisted via shared_preferences |
| `DodaAudioPlayer` | Background music + SFX; mute only silences background, never learning voices |

## Navigation
Simple `Navigator.push` / `Navigator.pop` — no named routes.
Flow: `HomeScreen` → `ProgressMapScreen` → activity screen (LetterTracing / Phonics / WordBuilding / NumberTracing).

## Data loading
`ContentLoader` (static, lazy-cached) loads JSON from `assets/data/`.
- `loadLetters(lang)` — always returns English letters (see DECISIONS.md)
- `loadNumbers()` — returns `numbers_en.json`
- `loadWords()` — returns `words.json`

## Audio
`DodaAudioPlayer` uses two `AudioPlayer` instances (audioplayers package):
- `_bgPlayer` — looping background music at volume 0.2
- `_sfxPlayer` — one-shot sound effects

Background music pauses when a learning screen opens and resumes on pop.
Audio files are optional — player silently swallows missing asset errors.

## Screens
| Screen | File | Notes |
|---|---|---|
| Home | `home_screen.dart` | Play + Parent buttons, language/mute toggles |
| Progress Map | `progress_map_screen.dart` | Physics bubbles (random movement, wall/collision bounce), savanna background; Sounds=square, First Words=star, others=circle. Each bubble shows an SVG icon (`svgAsset` on `LevelNode`) inside a white contour circle, falling back to `IconData` if no SVG. Rendered by `_BubbleIcon`. Requires `flutter_svg`. |
| Letter Tracing | `letter_tracing_screen.dart` | Split panel; left = info, right = TracingCanvas |
| Number Tracing | `number_tracing_screen.dart` | Same structure as letter tracing |
| Phonics | `phonics_screen.dart` | Tap-to-hear drum activity |
| Word Building | `word_building_screen.dart` | Drag-and-drop letter slots; tapping a tile plays the letter's sound |
| Parent | `parent_screen.dart` | PIN-gated dashboard (PIN = 1234) |

## Widgets
| Widget | File | Notes |
|---|---|---|
| `TracingCanvas` | `tracing_canvas.dart` | SVG-subset path, color picker; demo uses pencil hand, practice cursor shows same pencil icon |
| `AfricanBackground` | `african_decoration.dart` | Savanna gradient background |
| `ParchmentBackground` | `african_decoration.dart` | Parchment texture for activity screens |
| `AdinkraBadge` | `african_decoration.dart` | Circular badge with adinkra pattern |
| `DecorativeSun`, `KenteDivider` | `african_decoration.dart` | Decorative UI elements |
| `Mascot` | `mascot.dart` | Animated mascot with expression states |
| `RewardOverlay` | `reward_overlay.dart` | Star reward modal |
| `LanguageToggle` | `language_toggle.dart` | EN/RW flag toggle button |
| `StarCounter` | `star_counter.dart` | Running star total display |
