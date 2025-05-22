import 'dart:convert';

import 'package:openboard_wrapper/button_data.dart';
import 'package:openboard_wrapper/image_data.dart';
import 'package:test/test.dart';
import 'package:openboard_wrapper/obf.dart';
import './test_boards/board_strings.dart';
import 'file_system_mock.dart';

void main() {
  test('simple board to json', () {
    expect(Obf.fromJsonString(simpleBoard).toJson(), jsonDecode(simpleBoard));
  });

  test('simble board with errors json', () {
    expect(Obf.fromJsonString(simpleBoardWithErrors).toJson(),
        jsonDecode(simpleBoard));
  });
  test('inline data', () {
    expect(Obf.fromJsonString(inlineImages).toJson(), jsonDecode(inlineImages));
  });
  test('url image', () {
    expect(Obf.fromJsonString(urlImage).toJson(), jsonDecode(urlImage));
  });
  test('symbol image', () {
    expect(Obf.fromJsonString(symbolImage).toJson(), jsonDecode(symbolImage));
  });
  test('action/actions', () {
    expect(Obf.fromJsonString(actionAndActionsBoard).toJson(),
        jsonDecode(actionAndActionsBoard));
  });
  test('locales board test', () {
    expect(Obf.fromJsonString(stringsLocaleBoard).toJson(),
        jsonDecode(stringsLocaleBoard));
  });
  test('image and sound', () {
    expect(Obf.fromJsonString(imagesAndSounds).toJson(),
        jsonDecode(imagesAndSounds));
  });
  test('ext_properties', () {
    expect(
        Obf.fromJsonString(extProperties).toJson(), jsonDecode(extProperties));
  });
  test('all ext properties in board', () {
    Set<String> expected = {
      'ext_text_color',
      'ext_sound',
      'ext_hidden',
      'ext_animated',
      'ext_duration',
      'ext_playback_speed',
      'ext_theme',
    };

    expect(Obf.fromJsonString(extProperties).allExtendedPropertiesInFile,
        expected);
  });
  test('license', () {
    expect(Obf.fromJsonString(licenseBoard).toJson(), jsonDecode(licenseBoard));
  });
  test('voclization', () {
    expect(Obf.fromJsonString(vocilizationBoard).toJson(),
        jsonDecode(vocilizationBoard));
  });
  test('absolute position', () {
    expect(
        Obf.fromJsonString(absoluteBoard).toJson(), jsonDecode(absoluteBoard));
  });
  test('data url', () {
    expect(Obf.fromJsonString(dataUrlBoard).toJson(), jsonDecode(dataUrlBoard));
  });
  test('auto resolve id collisions', () {
    ButtonData b1 = ButtonData(id: 'b1');
    ButtonData b2 = ButtonData(id: 'b2');
    ImageData i1 = ImageData(id: 'b2');
    b1.image = i1;
    b2.image = i1;
    Obf obf = Obf(locale: 'en-us', name: 'joe', id: 'b1');
    obf.buttons.add(b1);
    obf.buttons.add(b2);
    obf.autoResolveAllIdCollisionsInFile();
    var ids = [obf.id, b1.id, b2.id, i1.id];
    for (int i = 0; i < ids.length; i++) {
      for (int j = i + 1; j < ids.length; j++) {
        expect(ids[i] != ids[j], true);
      }
    }
    expect(b1.image, b2.image);
  });
  test('to simple obz', () {
    Obf simpleBoard = getSimpleBoard();
    simpleBoard.path = "board/simpole";
    Map<String, dynamic> expectedManifest = {
      "root": simpleBoard.path,
      "paths": {
        "boards": {simpleBoard.id: simpleBoard.path}
      },
      "format": "open-board-0.1",
    };

    expect(expectedManifest, simpleBoard.toSimpleObz().manifestJson);
  });
  test('from file', () {
    Obf board = Obf.fromJsonString(extProperties);
    Map<String, dynamic> expected = board.toJson();
    board.path = "/ext.obf";
    Map<String, dynamic> actual = Obf.fromFile(MyFile.fromObf(board)).toJson();
    expect(expected, actual);
  });
  test('load board obf', () {
    Obf board = Obf.fromJsonString(linkedBoard2);
    expect(board.toJson(), jsonDecode(linkedBoard2));
  });
}

Obf getSimpleBoard() {
  return Obf.fromJsonString(simpleBoard);
}
