import 'dart:math';

import 'package:openboard_wrapper/src/_extensions/random_extensions.dart';

void addToMapIfNotNull(Map<String, dynamic> out, String key, dynamic value) {
  if (value != null) {
    out[key] = value;
  }
}

final _random = Random();

String generateRandomLetters({Random? random, required int letterCount}) {
  assert(letterCount > 0, "letter count should not be negative or zero");
  random ??= _random;
  String out = "";

  while (letterCount > 0) {
    out += _random.nextLetter();
    letterCount--;
  }
  return out;
}
