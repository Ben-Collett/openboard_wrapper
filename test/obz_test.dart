import 'dart:convert';
import 'dart:io';

import 'package:openboard_wrapper/_utils.dart';
import 'package:openboard_wrapper/obz.dart';
import 'package:openboard_wrapper/obf.dart';
import 'package:test/test.dart';
import './test_boards/board_strings.dart';
import './test_boards/manifest_stings.dart';
import 'file_system_mock.dart';

void main() {
  test('parse manifest', () {
    Obz obz = getTestObzWithoutManifest();
    obz.parseManifestString(manifestString);

    expect(obz.manifestJson, jsonDecode(manifestString));
  });
  test('parse second manifest to update path data', () {
    Obz obz = getTestObzWithoutManifest()
        .parseManifestString(manifestString)
        .parseManifestString(updatedPathsManifestString);

    expect(obz.manifestJson, jsonDecode(updatedPathsManifestString));
  });
  test('ext in manifest', () {
    Obz obz =
        getTestObzWithoutManifest().parseManifestString(manifestStringWithExt);
    expect(obz.manifestJson, jsonDecode(manifestStringWithExt));
  });
  test('ext in path', () {
    Obz obz = getTestObzWithoutManifest()
        .parseManifestString(manifestStringWithPathExt);
    expect(obz.manifestJson, jsonDecode(manifestStringWithPathExt));
  });
  test('merge manifest', () {
    Obz obz = getTestObzWithoutManifest()
        .parseManifestString(manifestString)
        .parseManifestString(toMergeString);
    expect(obz.manifestJson, jsonDecode(merged));
  });
  test('id collision auto resolve board id collision', () {
    Obz obz = getTestObzWithoutManifest()
        .addBoard(Obf.fromJsonString(absoluteBoard))
        .parseManifestString(manifestString)
        .autoResolveAllIdCollisionsInFile();
    obz.getBoard(id: 'absolute')?.path = "board/here";
    expect(obz.manifestJson, jsonDecode(idCollision));
  });
  test('id collision auto resolve all id collision', () {
    Obz obz = getTestObzWithoutManifest()
        .addBoard(Obf.fromJsonString(absoluteBoard))
        .parseManifestString(manifestString)
        .autoResolveAllIdCollisionsInFile();
    obz.getBoard(id: 'absolute')?.path = "board/here";

    Set<HasId> ids = Set.of(obz.boards);
    ids.addAll(obz.images);
    ids.addAll(obz.sounds);
    ids.addAll(obz.buttons);

    Set<String> seen = {};
    for (HasId id in ids) {
      assert(!seen.contains(id.id));
      seen.add(id.id);
    }

    expect(obz.manifestJson, jsonDecode(idCollision));
  });
  test('all ext in project test', () {
    Obz obz = getTestObzWithoutManifest()
        .parseManifestString(fullExtendedPorpertiesManfiest)
        .addBoard(Obf.fromJsonString(extProperties));

    Set<String> expected = {
      'ext_hotdog',
      'ext_hello',
      'ext_bye',
      'ext_text_color',
      'ext_sound',
      'ext_hidden',
      'ext_animated',
      'ext_duration',
      'ext_playback_speed',
      'ext_theme',
    };
    expect(obz.getAllExtendedPropertiesInProject(), expected);
  });
  test('full override', () {
    Obz obz = getTestObzWithoutManifest()
        .parseManifestString(manifestString)
        .parseManifestString(extProperties)
        .parseManifestString(toMergeString, fullOverride: true);
    expect(obz.manifestJson, jsonDecode(toMergeString));
  });
  test('from dir', () {
    Obz obz = getTestObzWithoutManifest();
    obz.parseManifestString(manifestString);

    toFiles(Obf board) => MyFile.fromObf(board);
    List<File> files = obz.boards.map(toFiles).toList();
    files.add(MyFile(path: 'manifest.json', content: obz.manifestString));

    Directory directory = MyDirectory(files);

    Obz fromDir = Obz.fromDirectory(directory);

    toJson(Obf board) => board.toJson();
    Set<Map<String, dynamic>> obzBoardJsons = obz.boards.map(toJson).toSet();
    Set<Map<String, dynamic>> fromDirJsons = obz.boards.map(toJson).toSet();

    expect(obzBoardJsons, fromDirJsons);
    expect(fromDir.manifestJson, obz.manifestJson);
  });
}

Obz getTestObzWithoutManifest() {
  Set<String> boardStrings = {
    absoluteBoard,
    urlImage,
    inlineImages,
    imagesAndSounds,
    vocilizationBoard
  };
  Obf toBoards(String board) => Obf.fromJsonString(board);

  return Obz(boards: boardStrings.map(toBoards));
}
