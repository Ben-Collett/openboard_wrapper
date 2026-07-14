import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:openboard_wrapper/src/has_ids.dart';

import 'button_data.dart';
import 'package:openboard_wrapper/src/obf.dart';
import 'image_data.dart';
import 'sound_data.dart';
import '_utils.dart';
import 'obz_exceptions.dart';

typedef Obz = EagarObz;

class EagarObz implements HasIds {
  Obf? root;
  Map<String, dynamic> manifestExtendedProperties;
  Map<String, dynamic> pathExtendedProperties;
  static const String defaultFormat = 'open-board-0.1';
  String format;

  ///this function is run on every path, it takes an input path and maps it to a sanitized output path
  ///the main use case for this function is converting windows paths using \\ to posix ones using /
  String Function(String)? sanitizeFilePathForManifest;
  final Set<Obf> _boards;
  UnmodifiableSetView<Obf>? _cachedBoards;
  UnmodifiableSetView<Obf> get boards {
    if (_cachedBoards != null) return _cachedBoards!;
    Set<Obf> out = Set.from(_boards);
    if (root != null && !_boards.contains(root)) {
      out.add(root!);
    }
    _cachedBoards = UnmodifiableSetView(out);
    return _cachedBoards!;
  }

  UnmodifiableListView<ImageData>? _cachedImages;
  UnmodifiableListView<ImageData> get images {
    if (_cachedImages != null) return _cachedImages!;
    Set<ImageData> result = {};
    for (Obf board in _boards) {
      board.collectImagesInto(result);
    }
    if (root != null && !_boards.contains(root)) {
      root!.collectImagesInto(result);
    }
    _cachedImages = UnmodifiableListView(result);
    return _cachedImages!;
  }

  UnmodifiableListView<SoundData>? _cachedSounds;
  UnmodifiableListView<SoundData> get sounds {
    if (_cachedSounds != null) return _cachedSounds!;
    Set<SoundData> result = {};
    for (Obf board in _boards) {
      board.collectSoundsInto(result);
    }
    if (root != null && !_boards.contains(root)) {
      root!.collectSoundsInto(result);
    }
    _cachedSounds = UnmodifiableListView(result);
    return _cachedSounds!;
  }

  ///removes all unrefrensed ImageData objects in the project object, you probably want to remove call [removeUnrefrensedButtons] first though.
  ///see also: [removedUnrefrencedButtons], [removedUnrefrencedSoundData];
  void removedUnrefrencedImageData() {
    for (Obf board in boards) {
      board.removeUnrefrencedSoundData();
    }
  }

  ///removes all unrefrensed sounddata objects in the project object, you probably want to remove call [removeUnrefrensedButtons] first though.
  ///see also: [removedUnrefrencedButtons], [removedUnrefrencedImageData];
  void removedUnrefrencedSoundData() {
    for (Obf board in boards) {
      board.removeUnrefrencedImageData();
    }
  }

  ///removes all unrefrensed buttons in the current project object, you will likely want to call [removedUnrefrencedImageData] and [removedUnrefrencedSoundData] afterwards.
  void removedUnrefrencedButtons() {
    for (Obf board in boards) {
      board.removeUnrefrencedButtons();
    }
  }

  UnmodifiableListView<ButtonData>? _cachedButtons;
  UnmodifiableListView<ButtonData> get buttons {
    if (_cachedButtons != null) return _cachedButtons!;
    Set<ButtonData> result = {};
    for (Obf board in _boards) {
      for (var b in board.buttons) {
        result.add(b);
      }
    }
    if (root != null && !_boards.contains(root)) {
      for (var b in root!.buttons) {
        result.add(b);
      }
    }
    _cachedButtons = UnmodifiableListView(result);
    return _cachedButtons!;
  }

  Map<Obf, String> get _boardPaths {
    return Map.fromIterable(boards.where((board) => board.path != null),
        value: (board) => board.path);
  }

  Map<ImageData, String> get _imagePaths {
    return Map.fromIterable(images.where((image) => image.path != null),
        value: (image) => image.path);
  }

  Map<SoundData, String> get _soundPaths {
    return Map.fromIterable(sounds.where((sound) => sound.path != null),
        value: (sound) => sound.path);
  }

  UnmodifiableSetView<String> getAllExtendedPropertiesInProject() {
    Set<String> out = Set.of(pathExtendedProperties.keys);
    out.addAll(manifestExtendedProperties.keys);
    for (Obf board in boards) {
      out.addAll(board.allExtendedPropertiesInFile);
    }
    return UnmodifiableSetView(out);
  }

  String get manifestString {
    return jsonEncode(manifestJson);
  }

  Map<String, dynamic> get manifestJson {
    if (root == null) {
      throw NoRootBoardException();
    }
    Obf rootBoard = root!;

    Map<Obf, String> boardPaths = _boardPaths;
    if (rootBoard.path == null) {
      throw NoRootPathException(root: rootBoard, boardPaths: boardPaths);
    }

    String sanitizePath(String s) {
      if (sanitizeFilePathForManifest != null) {
        return sanitizeFilePathForManifest!(s);
      }
      return s;
    }

    Map<String, dynamic> json = {
      'root': sanitizePath(root!.path!),
      'format': format
    };
    for (MapEntry<String, dynamic> entry
        in manifestExtendedProperties.entries) {
      json[entry.key] = entry.value;
    }
    Map<String, dynamic> paths = {};

    idToPath(HasId hasId, String path) => MapEntry(
          hasId.id,
          sanitizePath(path),
        );
    Map<ImageData, String> imagePaths = _imagePaths;
    Map<SoundData, String> soundPaths = _soundPaths;
    if (imagePaths.isNotEmpty) {
      paths['images'] = imagePaths.map(idToPath);
    }

    if (soundPaths.isNotEmpty) {
      paths['sounds'] = soundPaths.map(idToPath);
    }

    if (boardPaths.isNotEmpty) {
      paths['boards'] = boardPaths.map(idToPath);
    }

    if (pathExtendedProperties.isNotEmpty) {
      for (MapEntry<String, dynamic> entry in pathExtendedProperties.entries) {
        paths[entry.key] = entry.value;
      }
    }

    if (paths.isNotEmpty) {
      json['paths'] = paths;
    }

    return json;
  }

  Obf? findBoardById(String id) {
    for (var b in _boards) {
      if (b.id == id) return b;
    }
    if (root != null && root!.id == id) return root;
    return null;
  }

  @override
  Set<String> getAllIds() {
    Set<HasId> ids = {};
    ids.addAll(_boards);
    ids.addAll(buttons);
    ids.addAll(images);
    ids.addAll(sounds);
    return ids.map((b) => b.id).toSet();
  }

  EagarObz({
    this.format = defaultFormat,
    Iterable<Obf>? boards,
    Map<String, dynamic>? manifestExtensions,
    Map<String, dynamic>? pathExtensions,
    this.root,
  })  : _boards = boards?.toSet() ?? {},
        manifestExtendedProperties = manifestExtensions ?? {},
        pathExtendedProperties = pathExtensions ?? {};

  EagarObz.fromDirectory(Directory dir)
      : _boards = {},
        format = defaultFormat,
        manifestExtendedProperties = {},
        pathExtendedProperties = {} {
    File? manifest;
    _listBoardFiles(dir, (File f) {
      if (f.path.endsWith('.obf')) {
        _boards.add(Obf.fromFile(f));
      } else if (f.path.endsWith('manifest.json')) {
        manifest = f;
      }
    });
    var m = manifest;
    if (m != null) {
      parseManifestString(m.readAsStringSync());
    }
  }

  static void _listBoardFiles(Directory dir, void Function(File) callback) {
    for (FileSystemEntity entry in dir.listSync(recursive: false)) {
      if (entry is File) {
        callback(entry);
      } else if (entry is Directory) {
        String p = entry.path;
        int sep = p.lastIndexOf(Platform.pathSeparator);
        String name = sep >= 0 ? p.substring(sep + 1) : p;
        if (name != 'images' && name != 'sounds') {
          _listBoardFiles(entry, callback);
        }
      }
    }
  }
  EagarObz updateLinkedBoardsFromLoadData() {
    Map<String, Obf> paths = {};
    for (var board in _boards) {
      if (board.path != null) {
        paths[board.path!] = board;
      }
    }
    if (root != null && root!.path != null && !_boards.contains(root)) {
      paths[root!.path!] = root!;
    }

    for (var b in buttons) {
      var loadPath = b.loadBoardData?.path;
      if (loadPath != null) {
        b.linkedBoard = paths[loadPath];
      }
    }
    return this;
  }

  Obf? getBoard({required String id}) {
    for (var board in _boards) {
      if (board.id == id) return board;
    }
    if (root != null && root!.id == id) return root;
    return null;
  }

  ImageData? getImage({required String path}) {
    for (var image in images) {
      if (image.path == path) return image;
    }
    return null;
  }

  SoundData? getSound({required String path}) {
    for (var sound in sounds) {
      if (sound.path == path) return sound;
    }
    return null;
  }

  EagarObz parseManifestString(
    String json, {
    bool fullOverride = false,
    bool updateLinkedBoards = true,
  }) {
    return parseManifestJson(jsonDecode(json),
        fullOverride: fullOverride, updateLinkedBoards: updateLinkedBoards);
  }

  EagarObz parseManifestJson(
    Map<String, dynamic> manifestJson, {
    bool fullOverride = false,
    bool updateLinkedBoards = true,
  }) {
    if (fullOverride) {
      removeAllPaths();
      pathExtendedProperties = {};
      manifestExtendedProperties = {};

      root = null;
    }
    _updateFormatFromManifestJson(manifestJson);
    _updatePathsFromManifest(manifestJson);
    _attemptToUpdateRootFromManifest(manifestJson);
    if (updateLinkedBoards) {
      updateLinkedBoardsFromLoadData();
    }
    for (MapEntry<String, dynamic> entry in manifestJson.entries) {
      if (entry.key.startsWith('ext_')) {
        manifestExtendedProperties[entry.key] = entry.value;
      }
    }

    return this;
  }

  EagarObz removeAllPaths() {
    for (var board in _boards) {
      board.path = null;
    }
    if (root != null && !_boards.contains(root)) {
      root!.path = null;
    }
    for (var image in images) {
      image.path = null;
    }
    for (var sound in sounds) {
      sound.path = null;
    }
    return this;
  }

  EagarObz _updateFormatFromManifestJson(Map<String, dynamic> manifestJson) {
    if (manifestJson.containsKey('format')) {
      format = manifestJson['format'];
    }
    return this;
  }

  EagarObz _updatePathsFromManifest(Map<String, dynamic> manifestJson) {
    var paths = manifestJson['paths'];
    if (paths is! Map) return this;
    for (var key in paths.keys) {
      String keyStr = key.toString();
      if (keyStr.startsWith('ext_')) {
        pathExtendedProperties[keyStr] = paths[key];
        continue;
      }
      var value = paths[key];
      if (value is! Map) continue;
      if (keyStr == 'boards') {
        _updateHasIdAndPaths(boards, value);
      } else if (keyStr == 'images') {
        _updateHasIdAndPaths(images, value);
      } else if (keyStr == 'sounds') {
        _updateHasIdAndPaths(sounds, value);
      }
    }
    return this;
  }

  /// will only update values that appear in source
  EagarObz _updateHasIdAndPaths(Iterable<HasIdAndPath> toUpdate, Map source) {
    for (HasIdAndPath element in toUpdate) {
      if (source.containsKey(element.id)) {
        element.path = source[element.id];
      }
    }
    return this;
  }

  EagarObz _attemptToUpdateRootFromManifest(Map<String, dynamic> manifestJson) {
    const String rootKey = 'root';
    if (manifestJson[rootKey] is String) {
      _attemptToSetRootFromPath(manifestJson[rootKey]);
    }
    return this;
  }

  void removeBoard(Obf board) {
    if (root == board) {
      root = null;
    }
    _boards.remove(board);
    _invalidateCaches();
  }

  /// returns if the root path was set
  bool _attemptToSetRootFromPath(String path) {
    Obf? newRoot = getBoardFromPath(path);
    if (newRoot == null) {
      return false;
    }
    root = newRoot;
    return true;
  }

  EagarObz addBoard(Obf board) {
    _boards.add(board);
    _invalidateCaches();
    return this;
  }

  void _invalidateCaches() {
    _cachedBoards = null;
    _cachedImages = null;
    _cachedSounds = null;
    _cachedButtons = null;
  }

  Obf? getBoardFromPath(String path) {
    return boards.where((board) => board.path == path).firstOrNull;
  }

  UnmodifiableMapView<String, String> getIdToPathMap() {
    thisHasAPath(p) => p.path != null;
    List<Obf> boardsWithPaths = boards.where(thisHasAPath).toList();
    List<ImageData> imagesWithPaths = images.where(thisHasAPath).toList();
    List<SoundData> soundsWithPaths = sounds.where(thisHasAPath).toList();

    List<HasIdAndPath> list = List.of(boardsWithPaths);
    list.addAll(imagesWithPaths);
    list.addAll(soundsWithPaths);

    Map<String, String> out = {};
    out.addEntries(list.map((entry) => entry.idMappedToPath).nonNulls);
    return UnmodifiableMapView(out);
  }

  EagarObz autoResolveAllIdCollisionsInFile({
    String Function(String)? onCollision,
  }) {
    List<HasId> toResolve = [];
    toResolve.addAll(boards);
    toResolve.addAll(images);
    toResolve.addAll(sounds);
    toResolve.addAll(buttons);
    autoResolveIdCollisions(toResolve, onCollision: onCollision);
    return this;
  }
}
