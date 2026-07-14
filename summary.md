# Performance Optimizations Summary

## Baseline

- `profile_parse_1.dart` (total `EagarObz.fromDirectory` time): **255.7 ms**
- `profile_parse.dart` Phase 4 (`EagarObz.fromDirectory` in isolation): **166.3 ms**
- Board parsing (78 boards, 4531 buttons, 4489 images): **96.9 ms**
- File listing (4503 entries recursive): **27.5 ms**
- Manifest parsing: **19.0 ms**

## Final

- `profile_parse_1.dart`: **174.7 ms** (32% improvement)
- `profile_parse.dart` Phase 4: **107.6 ms** (36% improvement)
- Board parsing: **86.3 ms** (11% improvement)
- `fromDirectory` optimized listing: ~2 ms vs 25 ms full recursive

**Note:** The 50 ms target was not achievable with the current eager-parsing architecture. The dominant cost (~86 ms) is board JSON parsing + object construction (creating ~18,000 objects: 78 Obf, 4489 ImageData, 4531 ButtonData, 78 GridData, plus intermediate Maps from `jsonDecode`). A fundamentally different approach (lazy parsing, C-level JSON processing, or isolate-based parallelism) would be needed.

---

## Changes

### 1. `lib/src/_utils.dart` — `getExtendedPropertiesFromJson`

**Before:** Used `json.keys.where((k) => k.startsWith('ext_'))` which created an intermediate lazy iterable.

**After:** Direct `for` loop over keys with an `if` check, avoiding the `.where()` allocation.

**Impact:** Minor — reduces one intermediate `Iterable` per call. Called ~9000+ times during parsing (once per board, button, image, sound).

---

### 2. `lib/src/color_data.dart` — `extract()`

**Before:** Used `split(',')` → `.map()` → `.toList()` → `.where()` → `.cast()` → `.toList()`, creating 5+ intermediate collections per call.

**After:** Single-pass character iteration: scans for parentheses, then manually parses comma-separated values into a single output list.

**Impact:** Moderate — `extract()` is called ~9000 times (bg + border color per button). Each old call allocated 5+ intermediate lists; now it allocates 1.

---

### 3. `lib/src/obf.dart` — `Obf.images` and `Obf.sounds` getters

**Before:** `List.of(_images)` → `.addAll(buttons.map(...).nonNulls.toList())` → `.toSet()` → `.toList()`, creating 4+ intermediate collections.

**After:** `Set.of(_images)` → iterate buttons → `.add()` to Set → `.toList()`, creating 2 intermediate collections.

**Impact:** Moderate — called during manifest path updates and whenever images/sounds are accessed. Reduces memory churn.

---

### 4. `lib/src/obf.dart` — Added `collectImagesInto` / `collectSoundsInto`

**New methods:** Allow callers (like `EagarObz`) to collect images/sounds directly into an existing `Set`, avoiding the creation of intermediate per-board lists. The `EagarObz.images` getter now uses these methods instead of calling `board.images` and then iterating the result.

**Impact:** Significant for manifest path updates — each `ImageData` now has its hash computed once (in the final `EagarObz.images` Set) instead of twice (once per-board, once in the aggregate).

---

### 5. `lib/src/obf.dart` — `getImageDataFromJson`, `getSoundDataFromJson`, `getButtonsDataFromJson`

**Before:** Created a throwaway `List? out = []` then replaced it, followed by `.map().toList()` which created lazy iterables.

**After:** Direct `for` loop with `.add()`, avoiding the intermediate `.map()` iterable.

**Impact:** Minor — cleaner and avoids lazy iterable allocation overhead.

---

### 6. `lib/src/obf.dart` — `ImageData.decodeJson` factory

**Before:** Was a generative constructor that first initialized all fields with defaults, then overwrote them in the body. The default `extendedProperties = {}` Map was allocated then immediately replaced.

**After:** Factory constructor that returns `ImageData(...)` with all fields provided directly, avoiding the default initialization + overwrite pattern.

**Impact:** Minor — avoids one default Map allocation per image that was immediately discarded.

---

### 7. `lib/src/obf.dart` — `InlineData.decode`

**Before:** Used repeated `indexOf` calls and string slicing without anchoring searches, causing redundant scanning.

**After:** Anchored `indexOf` calls to known positions (`indexOf(';', ...)`) and reduced intermediate string allocations.

**Impact:** Minor — only affects boards with inline image data (72 images in one board in the test dataset).

---

### 8. `lib/src/grid_data.dart` — `GridData.fromStringList`

**Before:** Two-pass approach: first extracted string IDs into a `List<List<String?>>`, then resolved each to `ButtonData` in a second pass.

**After:** Single-pass: directly resolves `ButtonData` from the Map while iterating, eliminating the intermediate `List<List<String?>>`.

**Impact:** Moderate — reduces allocations and iterations for every board's grid (78 boards).

---

### 9. `lib/src/obz.dart` — `EagarObz` getter caching

**Added caching for:** `boards`, `images`, `sounds`, `buttons` getters.

**Invalidation:** `addBoard()` and `removeBoard()` call `_invalidateCaches()`.

**Also optimized:** `images`/`sounds`/`buttons` iterates `_boards` directly instead of going through the `boards` getter (which creates a `Set.from(_boards)` each time).

**Impact:** Significant — the `boards` getter was creating a `Set.from()` copy on every access (called multiple times during manifest parsing). Images/sounds getters also recomputed from scratch each time. With caching, the result is computed once and reused.

---

### 10. `lib/src/obz.dart` — Optimized directory listing in `EagarObz.fromDirectory`

**Before:** Used `dir.listSync(recursive: true)` which listed all 4503 entries (including 4400+ image files in the `images/` subdirectory).

**After:** Custom `_listBoardFiles` helper that recursively walks directories but skips `images/` and `sounds/` subdirectories, reducing listed entries from ~4503 to ~85.

**Impact:** **Major** — saves ~22 ms of file system listing time. The `images/` directory contains 4400+ files that are never boards, so there's no behavioral change for standard Open Board format data.

---

### 11. `lib/src/obz.dart` — `_updatePathsFromManifest`

**Before:** Used `paths.entries` (creating `MapEntry` objects), repeated `entry.key.toString()` calls, and type checks for every entry.

**After:** Iterates `paths.keys` directly, checks key string once, accesses value with `paths[key]`.

**Impact:** Minor — fewer temporary `MapEntry` objects.

---

### 12. `lib/src/obz.dart` — `_updateHasIdAndPaths`

**Before:** Used `.where()` to filter elements, creating an intermediate lazy iterable.

**After:** `containsKey` check inside the loop, only setting path when found.

**Impact:** Minor — avoids the `.where()` lazy iterable for 4489 images.

---

### 13. `lib/src/obz.dart` — `findBoardById`, `getBoard`, `getImage`, `getSound`

**Before:** Used `.where(...).firstOrNull` which created intermediate lazy iterables and sometimes went through the `boards` getter (which created a `Set.from()` copy).

**After:** Direct `for` loops with early return.

**Impact:** Minor — these are not called during the parsing hot path but improve general performance.

---

### 14. `lib/src/button_data.dart` — `AbsoluteDimensionData.fromJson`

**Before:** Used `num.parse(json[key].toString()).toDouble()` which parsed a string unnecessarily when the value was already a `num`.

**After:** `(json[key] as num?)?.toDouble() ?? 0` — avoids the string round-trip.

**Impact:** Minimal — absolute dimensions are rare (0 in the test dataset).

---

### 15. `lib/` — Other minor optimizations

- `ButtonData.decode`: Eliminated redundant `json.containsKey` + `toString()` calls by using a single `var imgId = json[imageKey]` and null check.
- `ButtonData.decode`: Simplified absolute dimension detection (early break on first non-null key).
- Fixed bug in `EagarObz.removeBoard`: `root == null;` → `root = null;`.
