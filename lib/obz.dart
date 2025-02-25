import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:openboard_wrapper/button_data.dart';
import 'package:openboard_wrapper/obf.dart';
import 'package:openboard_wrapper/image_data.dart';
import 'package:openboard_wrapper/sound_data.dart';
import 'package:openboard_wrapper/_utils.dart';

class Obz {
  Obf? root;
  Map<String, dynamic> manifestExtendedProperties;
  Map<String, dynamic> pathExtendedProperties;
  static const String defaultFormat = 'open-board-0.1';
  String format;
  final Set<Obf> _boards;
  UnmodifiableSetView<Obf> get boards {
    Set<Obf> out = Set.from(_boards);
    if (root != null && !_boards.contains(root)) {
      out.add(root!);
    }
    return UnmodifiableSetView(out);
  }

  UnmodifiableListView<ImageData> get images {
    Set<ImageData> images = {};
    for (Obf board in boards) {
      images.addAll(board.images);
    }
    return UnmodifiableListView(images);
  }

  UnmodifiableListView<SoundData> get sounds {
    Set<SoundData> sounds = {};
    for (Obf board in boards) {
      sounds.addAll(board.sounds);
    }

    return UnmodifiableListView(sounds);
  }

  UnmodifiableListView<ButtonData> get buttons {
    Set<ButtonData> buttons = {};
    for (Obf board in boards) {
      buttons.addAll(board.buttons);
    }

    return UnmodifiableListView(buttons);
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

    Map<String, dynamic> json = {'root': root!.path, 'format': format};
    for (MapEntry<String, dynamic> entry
        in manifestExtendedProperties.entries) {
      json[entry.key] = entry.value;
    }
    Map<String, dynamic> paths = {};

    idToPath(HasId hasId, String path) => MapEntry(hasId.id, path);
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
        print(entry);
        paths[entry.key] = entry.value;
      }
    }

    if (paths.isNotEmpty) {
      json['paths'] = paths;
    }

    return json;
  }

  Obz({
    this.format = defaultFormat,
    Iterable<Obf>? boards,
    Map<String, dynamic>? manifestExtensions,
    Map<String, dynamic>? pathExtensions,
    this.root,
  })  : _boards = boards?.toSet() ?? {},
        manifestExtendedProperties = manifestExtensions ?? {},
        pathExtendedProperties = pathExtensions ?? {};

  Obz.fromDirectory(Directory dir)
      : _boards = {},
        format = defaultFormat,
        manifestExtendedProperties = {},
        pathExtendedProperties = {} {
    File? manifest;
    for (FileSystemEntity entry in dir.listSync(recursive: true)) {
      if (entry is File) {
        if (entry.path.endsWith('.obf')) {
          _boards.add(Obf.fromFile(entry));
        } else if (entry.path.endsWith("manifest.json")) {
          manifest = entry;
        }
      }
    }
    if (manifest != null) {
      parseManifestString(manifest.readAsStringSync());
    }
  }

  Obf? getBoard({required String id}) {
    return boards.where((board) => board.id == id).firstOrNull;
  }

  ImageData? getImage({required String path}) {
    return images.where((image) => image.path == path).firstOrNull;
  }

  SoundData? getSound({required String path}) {
    return sounds.where((sound) => sound.path == path).firstOrNull;
  }

  Obz parseManifestString(String json, {bool fullOverride = false}) {
    return parseManifestJson(jsonDecode(json), fullOverride: fullOverride);
  }

  Obz parseManifestJson(
    Map<String, dynamic> manifestJson, {
    bool fullOverride = false,
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

    for (MapEntry<String, dynamic> entry in manifestJson.entries) {
      if (entry.key.startsWith('ext_')) {
        manifestExtendedProperties[entry.key] = entry.value;
      }
    }

    return this;
  }

  Obz removeAllPaths() {
    List<HasIdAndPath> toUpdate = List.of(boards);
    toUpdate.addAll(images);
    toUpdate.addAll(sounds);

    void removePath(HasIdAndPath path) => path.path = null;
    toUpdate.forEach(removePath);

    return this;
  }

  Obz _updateFormatFromManifestJson(Map<String, dynamic> manifestJson) {
    if (manifestJson.containsKey('format')) {
      format = manifestJson['format'];
    }
    return this;
  }

  Obz _updatePathsFromManifest(Map<String, dynamic> manifestJson) {
    if (manifestJson['paths'] is Map) {
      Map paths = manifestJson['paths'];
      for (MapEntry entry in paths.entries) {
        if (entry.key.toString().startsWith('ext_')) {
          pathExtendedProperties[entry.key.toString()] = entry.value;
          continue;
        }
        Map source = entry.value;
        if (entry.key == 'boards' && entry.value is Map) {
          _updateHasIdAndPaths(boards, source);
        } else if (entry.key == 'images' && entry.value is Map) {
          _updateHasIdAndPaths(images, source);
        } else if (entry.key == 'sounds' && entry.value is Map) {
          _updateHasIdAndPaths(sounds, source);
        }
      }
    }
    return this;
  }

  /// will only update values that appear in source
  Obz _updateHasIdAndPaths(Iterable<HasIdAndPath> toUpdate, Map source) {
    bool sourceHasId(HasId hasId) => source.containsKey(hasId.id);
    toUpdate = toUpdate.where(sourceHasId);

    for (HasIdAndPath element in toUpdate) {
      element.path = source[element.id];
    }
    return this;
  }

  Obz _attemptToUpdateRootFromManifest(Map<String, dynamic> manifestJson) {
    const String rootKey = 'root';
    if (manifestJson[rootKey] is String) {
      _attemptToSetRootFromPath(manifestJson[rootKey]);
    }
    return this;
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

  Obz addBoard(Obf board) {
    _boards.add(board);
    return this;
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

  Obz autoResolveAllIdCollisionsInFile({
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

class NoRootBoardException implements Exception {
  @override
  String toString() {
    return "The manifest must have a root board";
  }
}

class NoRootPathException implements Exception {
  final Obf root;
  final Map<Obf, String> boardPaths;
  NoRootPathException({required this.root, required this.boardPaths});
  @override
  String toString() {
    return "The root board must have a path defined in boardPaths, root id = ${root.id}, boardPaths = $boardPaths";
  }
}
