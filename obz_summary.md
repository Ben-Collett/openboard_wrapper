# `Obz` Class Member Usage Summary

Source: `package:openboard_wrapper/obz.dart` (git ref `039ed299090eb91e712d89afb25a33cbd61a6788`)

## 1. Classes that extend `Obz`

### `ParrotProject` — `lib/backend/project/parrot_project.dart:21`
```dart
class ParrotProject extends Obz with AACProject {
```

## 2. Overridden `Obz` members in `ParrotProject`

| Member | Kind | File & Line |
|---|---|---|
| `sanitizeFilePathForManifest` | field → getter override | `parrot_project.dart:31-32` |
| `parseManifestString(String json, ...)` | method override (calls super) | `parrot_project.dart:186-197` |
| `parseManifestJson(Map<String, dynamic> manifestJson, ...)` | method override (calls super) | `parrot_project.dart:200-214` |

## 3. `Obz` members used in the project

### Fields

| Field | Usage | File(s) & Lines |
|---|---|---|
| `root` | read | `board.dart:80,406`, `state_restoration_utils.dart:140,149`, `event_handler.dart:346`, `button_config.dart:417` |
| `root` | write (set) | `parrot_actions.dart:88`, `board_select_screen.dart:39`, `legacy_actions.dart:78`, `board_screen_test.dart:40` |
| `manifestExtendedProperties` | read/write | `parrot_project.dart:41-44,48,57-58,67,75,112,121` (via access in subclass) |
| `format` | (not used externally — only used internally by Obz) | — |

### Getters

| Getter | Usage | File(s) & Lines |
|---|---|---|
| `boards` | read | `parrot_project.dart:62,179`, `write_test.dart:21`, `board_select.dart:119` |
| `images` | read | `file_cleanup_data.dart:33`, `button_data_extensions.dart:136` |
| `sounds` | read | `file_cleanup_data.dart:37`, `button_data_extensions.dart:144` |
| `manifestJson` | read | `parrot_project.dart:182`, `write_test.dart:19` |

### Methods

| Method | Usage | File(s) & Lines |
|---|---|---|
| `Obz()` (constructor) | `ParrotProject(...) : super()` | `parrot_project.dart:61-68` |
| `Obz.fromDirectory(Directory)` | `Obz.fromDirectory(dir)` | `write_test.dart:64` |
| `parseManifestString(...)` | `project.parseManifestString(...)` | `default_project.dart.dart:40`, `write_test.dart:101`, `parrot_project.dart:191` (super call) |
| `parseManifestJson(...)` | `out.parseManifestJson(json)` | `write_test.dart:152`, `parrot_project.dart:182,208` (super call) |
| `findBoardById(String)` | `project.findBoardById(id)` | `event_handler.dart:112,301`, `project_events.dart:128,252,296,330,361,478,818`, `state_restoration_utils.dart:144,187`, `parrot_button.dart:203`, `button_config.dart:360`, `selection_history.dart:61,102`, `swap_data.dart:73,74,179,209`, `button_data_extensions.dart:159` |
| `addBoard(Obf)` | `project.addBoard(board)` | `project_events.dart:100`, `event_handler.dart:418`, `create_board.dart:195`, `board_screen_test.dart:41`, `legacy_actions.dart:75-76`, `parrot_actions.dart:85-86`, `board_select_screen.dart:40` |
| `removeBoard(Obf)` | `handler.project.removeBoard(board)` | `project_events.dart:132` |
| `removedUnrefrencedButtons()` | `project.removedUnrefrencedButtons()` | `board_screen.dart:130` |
| `removedUnrefrencedImageData()` | `project.removedUnrefrencedImageData()` | `board_screen.dart:131` |
| `removedUnrefrencedSoundData()` | `project.removedUnrefrencedSoundData()` | `board_screen.dart:132` |
| `generateRandomBoardId(Obz?)` | `Obz.generateRandomBoardId(project)` | `create_board.dart:191` |
| `generateButtonId(Obz?)` | `Obz.generateButtonId(project)` | `parrot_button.dart:146`, `board.dart:359` |
| `generateSoundId(Obz?)` | `Obz.generateSoundId(project)` | `button_config.dart:657,708,749` |
| `generateImageId(Obz?)` | `Obz.generateImageId(project)` | `button_config.dart:809` |

### Type annotations only (no member access)

| Context | File & Line |
|---|---|
| `Future<void> equalProjectes(Obz b1, Obz b2)` | `write_test.dart:17` |
| `factory ParrotProject.fromObz(Obz obz, ...)` | `parrot_project.dart:177` |
| `Obz simpleObz = board.toSimpleObz()` | `import_utils.dart:65` |
| `Obz project = widget.eventHandler.project` | `create_board.dart:187` |

## 4. `Obz` members NOT used in the project

The following `Obz` public members have **no references** in the project codebase:

- `buttons` getter (returns `UnmodifiableListView<ButtonData>`)
- `allIds` getter
- `manifestString` getter
- `generateGloballyUniqueId(...)` method
- `getAllExtendedPropertiesInProject()` method
- `updateLinkedBoardsFromLoadData()` method
- `getBoard({required String id})` method
- `getImage({required String path})` method
- `getSound({required String path})` method
- `removeAllPaths()` method
- `getBoardFromPath(String path)` method
- `getIdToPathMap()` method
- `autoResolveAllIdCollisionsInFile(...)` method
- `defaultFormat` static const
