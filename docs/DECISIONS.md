# DoDa — Design Decisions

Decisions that are non-obvious or would be confusing without context.

---

## Package name: org.longhornshield.doda (2026-06-07)
Android `applicationId` and iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER` are set to `org.longhornshield.doda`.

**Why:** Advised change from the previous `doda.longhornshield.org` to follow standard reverse-domain convention and match the intended store identity.

**Where it lives:** `android/app/build.gradle.kts` (namespace + applicationId), `android/app/src/main/kotlin/org/longhornshield/doda/MainActivity.kt` (package declaration), `ios/Runner.xcodeproj/project.pbxproj` (3 Runner + 3 RunnerTests entries), `macos/Runner/Configs/AppInfo.xcconfig`, `macos/Runner.xcodeproj/project.pbxproj` (3 RunnerTests entries).

---

## SVG icons on progress-map bubbles (2026-06-07)
Each level bubble shows an SVG image inside a white circular contour ring rather than a Material `IconData`.

**Why:** Custom artwork is more engaging for kids than generic icons.

**Where it lives:** `LevelNode.svgAsset` field in `progress_map_screen.dart`; rendered by `_BubbleIcon` (white `Border` container + `SvgPicture.asset` tinted white via `ColorFilter`). Falls back to `IconData` when `svgAsset` is null. Requires `flutter_svg` package. SVG files live in `assets/images/ui/`.

---

## Kinyarwanda toggle disabled (2026-06-07)
The RW chip in `LanguageToggle` is greyed out and non-tappable. Tapping it shows a "Kinyarwanda — coming soon" tooltip instead of switching language.

**Why:** Kinyarwanda content (alphabet order, audio, curriculum alignment) is not ready. The toggle still appears so it's clear bilingual support is planned, but it must not be usable.

**Where it lives:** `lib/widgets/language_toggle.dart` — RW chip wrapped in `Tooltip`, `disabled: true` passed to `_LangChip`, no `onTap` handler.

---

## English only (2026-06-07)
Letter and number tracing screens always load English content (`letters_en.json`), regardless of the language toggle.

**Why:** The Kinyarwanda alphabet (`letters_rw.json`) has a different letter set and order (e.g. Cy, Ny instead of D, E; 24 letters not 26). The level index ranges in `kLevels` (e.g. "A–E" = indices 0–4) were authored for the English alphabet; applying them to the RW file produced wrong letters. Rather than maintain two separate index systems, the decision was to focus on English first and wire up Kinyarwanda letter tracing only when the curriculum is explicitly designed for it.

**Where it lives:** `ContentLoader.loadLetters()` always returns `_lettersEn`. The language toggle still works for UI labels and audio in other screens.

---

## Progress map: floating scattered bubbles (2026-06-07)
Level nodes are positioned via `Stack` + `Positioned` using fixed fractional coordinates rather than a horizontal scrolling `Row`.

**Why:** The horizontal line of bubbles felt boring. Scattered floating bubbles (each with unique float speed, amplitude, and phase) fill the screen and feel more inviting for kids. The title also changed to "What do you want to learn?" to invite exploration rather than imply a linear path.

**Where it lives:** `_kPositions` constant in `progress_map_screen.dart`; `_LevelBubble` handles float animation.

---

## Mute button on home screen (2026-06-07)
A volume icon in the home screen top bar toggles all audio on/off. Icon switches between `volume_up_rounded` and `volume_off_rounded` and dims when muted.

**Why:** Kids (or parents) need a quick way to silence the app without going into settings.

**Where it lives:** `home_screen.dart` top bar. `DodaAudioPlayer` extends `ChangeNotifier` and calls `notifyListeners()` in `toggleMute()` so the icon rebuilds reactively. Registered as `ChangeNotifierProvider` in `main.dart`.

---

## Background music pauses during learning
Music stops when any activity screen opens, resumes on pop.

**Why:** Background music overlaps with letter/word audio pronunciation, making it hard for kids to hear what they're learning.

**Where it lives:** `DodaAudioPlayer.pauseBackground()` / `resumeBackground()` called in `ProgressMapScreen`'s `onTap` around `Navigator.push`.

---

## Tracing canvas: 0–100 coordinate grid
Stroke paths are authored in a normalised 0–100 space, not in pixels.

**Why:** Decouples content from screen size — the same path works on any tablet. The canvas scales coordinates at paint time via `_scale()`.

---

## Parent PIN hard-coded to 1234
**Where it lives:** `lib/screens/parent_screen.dart`. Change it there; no env var or config file.

---

## kotlin.incremental=false in android/gradle.properties (2026-06-07)
Kotlin incremental compilation is disabled for the Android build.

**Why:** The project lives on `D:\` while the Pub cache is on `C:\`. The Kotlin incremental compiler cannot compute relative paths between files on different drives (Windows-only bug), causing a hard build failure (`IllegalArgumentException: this and base files have different roots`). Disabling incremental compilation avoids the cross-drive path calculation entirely.

**Impact:** All Kotlin files recompile on every build. Adds roughly 10–30 seconds to Android build times. No effect on the app itself. The correct long-term fix is to move the project or set `PUB_CACHE` to the same drive, but this workaround is safe to keep permanently.

**Where it lives:** `android/gradle.properties`.

---

## Audio files optional
`DodaAudioPlayer` silently swallows missing asset errors so the app runs without any audio files present.

**Why:** Placeholder stubs exist in `assets/audio/` but real recordings haven't been produced yet.
