# DoDa — Letter & Number Tracing Implementation Plan

## Current state
The tracing canvas (`lib/widgets/tracing_canvas.dart`) is fully rebuilt with:
- **SVG-subset path parsing** (M, L, Q, C commands on a 0–100 grid)
- **Dashed guide rendering** using `PathMetrics` for even dash spacing
- **Numbered start circles** with pulse animation on the active stroke
- **Direction arrows** along the active guide path
- **Per-stroke accuracy** using nearest-point distance (28px threshold)
- **Color picker** — child picks one of 6 African-themed pen colours
- **Cursor overlay** — crosshair + dot shows exactly where the finger is
- **Smooth drawing** — quadratic Bézier interpolation between touch points
- **Stroke progress dots** below canvas (green = done, orange = active, sand = pending)

---

## What we still need for a polished tracing experience

### 1. High-quality stroke paths for all 26 letters (+ a–z lowercase)

Each letter in `assets/data/letters_en.json` needs a `stroke_paths` array of SVG commands
on a **0–100 coordinate grid** (0,0 = top-left, 100,100 = bottom-right).

#### Format
```json
"stroke_paths": [
  "M 50 10 L 10 90",       // stroke 1
  "M 50 10 L 90 90",       // stroke 2
  "M 25 60 L 75 60"        // stroke 3
]
```

#### Supported commands
| Command | Meaning | Example |
|---------|---------|---------|
| `M x y` | Move to (start of stroke) | `M 50 10` |
| `L x y` | Line to | `L 10 90` |
| `Q cx cy x y` | Quadratic Bézier | `Q 10 50 10 80` |
| `C cx1 cy1 cx2 cy2 x y` | Cubic Bézier | `C 80 10 80 90 20 90` |

#### Letters that need careful multi-stroke paths
| Letter | Strokes | Notes |
|--------|---------|-------|
| A | 3 | Left diagonal, right diagonal, crossbar |
| B | 2 | Vertical line, two bumps (Bézier) |
| D | 2 | Vertical line, right arc |
| E | 3 | Vertical, top bar, middle bar (+ optional bottom) |
| F | 2 | Vertical, top bar, middle bar |
| G | 2 | C arc, horizontal inward |
| H | 3 | Left vertical, right vertical, crossbar |
| I | 1–3 | Vertical (+ optional top/bottom serifs) |
| J | 1 | Vertical + hook |
| K | 2 | Vertical, two diagonals |
| M | 2 | Two outer verticals + V peak |
| N | 2 | Two verticals + diagonal |
| R | 2 | B upper half + kick leg |
| T | 2 | Horizontal top, vertical stem |
| X | 2 | Two crossing diagonals |
| Y | 2 | Two upper diagonals + lower stem |

#### Recommended reference
Use **D'Nealian** or **Zaner-Bloser** stroke guides for children's letter formation.
A useful free resource: [fontsintofont.com letter paths](https://www.fontsintofont.com)

---

### 2. Number stroke paths (0–9)

Add a separate `assets/data/numbers_en.json` with the same format.

```json
[
  {
    "id": "0",
    "letter": "0",
    "letter_lower": "0",
    "sound_description": "Zero",
    "audio_file": "assets/audio/en/numbers/0.mp3",
    "example_word": "zero",
    "stroke_paths": ["M 50 10 Q 90 10 90 50 Q 90 90 50 90 Q 10 90 10 50 Q 10 10 50 10"],
    "tracing_difficulty": 1
  }
]
```

| Number | Strokes | Notes |
|--------|---------|-------|
| 0 | 1 | Oval, single continuous stroke |
| 1 | 1–2 | Vertical (+ optional top flag) |
| 2 | 1 | Curve + horizontal base |
| 3 | 1 | Two stacked arcs |
| 4 | 2 | Vertical + right-to-left horizontal, then vertical drop |
| 5 | 2 | Top horizontal + arc, then top hat |
| 6 | 1 | Curve + loop |
| 7 | 1–2 | Horizontal + diagonal (+ optional crossbar) |
| 8 | 1 | S-curve forming two loops |
| 9 | 1 | Loop + descender |

---

### 3. UI additions needed

#### a. Tracing mode toggle (uppercase / lowercase / numbers)
- Add a segmented toggle at the top of `LetterTracingScreen`
- Lowercase paths need separate entries (lower-case `a` is very different from `A`)

#### b. Animated stroke guide (optional enhancement)
- Animate a dot travelling along the guide path before the child starts
- Implementation: `PathMetrics` + `AnimationController` + `drawCircle` at metric.getTangentForOffset

#### c. Step-by-step stroke reveal
- Show only stroke N until the child completes it, then reveal stroke N+1
- Already partially implemented (`activeStrokeIndex`) — just hide future strokes

#### d. Progress within a stroke
- Colour the guide path green progressively as the user covers it
- Implementation: track `hitFraction` per guide point, paint covered portion in green

#### e. Haptic feedback
- Import `flutter/services.dart` and call `HapticFeedback.lightImpact()` on stroke completion

---

### 4. Accuracy calibration

Current thresholds:
- > 80% coverage → 3 stars
- > 50% coverage → 2 stars
- > 30% triggers completion → 1 star

**Recommended tuning for kids (age 3–6):**
- Lower completion threshold to 25% (motor skills are developing)
- Widen hit radius from 28px to 36px on tablets
- Award 3 stars for > 65% (not 80%) — encourage rather than frustrate

---

### 5. Audio cues for tracing

| Event | Sound |
|-------|-------|
| Stroke start | Soft tick |
| Stroke complete | Chime |
| All strokes done | Celebratory jingle + letter name pronounced |
| Wrong area | Gentle "try here" cue |

Audio files to create: `assets/audio/en/letters/a.mp3` … `z.mp3` (letter name + pronunciation)

---

### 6. Numbers as a separate level type

Add to `kLevels` in `progress_map_screen.dart`:

```dart
LevelNode(
  id: 'numbers_1',
  titleEn: 'Numbers 1–5',
  titleRw: 'Imibare 1–5',
  icon: Icons.tag_rounded,
  color: kColorNight,
  prerequisites: ['tracing_1'],
  screenBuilder: (_) => const LetterTracingScreen(
    levelId: 'numbers_1',
    startLetter: 0,
    endLetter: 4,
    dataSource: 'numbers', // add dataSource param to LetterTracingScreen
  ),
),
```

This requires a small refactor: `ContentLoader.loadLetters(lang)` → `ContentLoader.loadContent(lang, source)` where `source` is `'letters'` or `'numbers'`.

---

## Quick-start checklist

- [ ] Fill in stroke paths for letters A–Z in `assets/data/letters_en.json`
- [ ] Create `assets/data/numbers_en.json` with stroke paths for 0–9
- [ ] Record or source audio for letters (`a.mp3` … `z.mp3`)
- [ ] Record or source audio for numbers (`0.mp3` … `9.mp3`)
- [ ] Add `dataSource` parameter to `LetterTracingScreen` for numbers mode
- [ ] Add number levels to `kLevels`
- [ ] Test on a real tablet — accuracy thresholds may need tuning
- [ ] Add haptic feedback on stroke completion
