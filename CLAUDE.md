# DoDa — Claude Code Project Guide

## What is DoDa?
Kids learning app targeting Android/iOS tablets. Flutter, landscape-only, Material 3.
**Current focus: English only.** Kinyarwanda support is planned but not active in learning screens.

## Documentation — read before working
- `docs/ARCHITECTURE.md` — folder structure, screens, widgets, providers, navigation
- `docs/DECISIONS.md` — non-obvious decisions with rationale (read this before changing anything)
- `docs/TRACING_PLAN.md` — letter/number tracing roadmap and stroke path format

## Documentation rule
After every code change, update the relevant `docs/` file and this file if needed.
Keep `CLAUDE.md` short — detail lives in `docs/`.

## Key conventions
- All colours live in `lib/theme.dart` — use `kColor*` constants, never hard-code hex.
- African decoration widgets live in `lib/widgets/african_decoration.dart`.
- Every activity screen uses `ParchmentBackground`; progress map uses `AfricanBackground`.
- Landscape only — always test in landscape viewport.
- State management: Provider only (no Riverpod, no Bloc).
- Audio files are optional — `DodaAudioPlayer` silently skips missing assets.

## Running the app
```bash
flutter pub get
flutter run -d <device>   # or use /run skill
```

## Slash commands
- `/run`    — start the app on a connected device
- `/check`  — run `flutter analyze` and `flutter test`
- `/assets` — list all asset files and flag missing ones

## Package name
`org.longhornshield.doda` — Android applicationId and iOS/macOS bundle identifier. See `DECISIONS.md` for affected files.

## Parent PIN
Hard-coded to `1234` in `lib/screens/parent_screen.dart`.
