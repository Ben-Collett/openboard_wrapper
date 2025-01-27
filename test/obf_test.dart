import 'dart:convert';

import 'package:openboard_searlizer/button_data.dart';
import 'package:openboard_searlizer/image_data.dart';
import 'package:test/test.dart';
import 'package:openboard_searlizer/obf.dart';
import './test_boards/board_strings.dart';

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
  test('image and sound', () {
    expect(Obf.fromJsonString(imagesAndSounds).toJson(),
        jsonDecode(imagesAndSounds));
  });
  test('ext_properties', () {
    expect(
        Obf.fromJsonString(extProperties).toJson(), jsonDecode(extProperties));
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
}

Obf getSimpleBoard() {
  return Obf.fromJsonString(simpleBoard);
}
