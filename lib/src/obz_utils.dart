import "dart:math";
import "has_ids.dart";
import "_utils.dart";

const defaultRandomLetterIdCount = 3;

String generateRandomBoardId(
  HasIds? obz, {
  int randomLetterCount = defaultRandomLetterIdCount,
  Random? random,
}) =>
    generateRandomId(
      prefix: "board",
      randomLetterCount: randomLetterCount,
      obz: obz,
      random: random,
    );
String generateButtonId(
  HasIds? obz, {
  int randomLetterCount = defaultRandomLetterIdCount,
  Random? random,
}) =>
    generateRandomId(
      prefix: "btn",
      randomLetterCount: randomLetterCount,
      obz: obz,
      random: random,
    );
String generateImageId(
  HasIds? obz, {
  int randomLetterCount = defaultRandomLetterIdCount,
  Random? random,
}) =>
    generateRandomId(
      prefix: "img",
      randomLetterCount: randomLetterCount,
      obz: obz,
      random: random,
    );
String generateSoundId(
  HasIds? obz, {
  int randomLetterCount = defaultRandomLetterIdCount,
  Random? random,
}) =>
    generateRandomId(
      prefix: "sound",
      randomLetterCount: randomLetterCount,
      obz: obz,
      random: random,
    );

String generateRandomId({
  required String prefix,
  required int randomLetterCount,
  HasIds? obz,
  Random? random,
}) {
  String out = prefix;
  if (randomLetterCount > 0) {
    out += "_${generateRandomLetters(
      letterCount: randomLetterCount,
      random: random,
    )}";
  }

  if (obz != null) {
    out = HasIds.generateUniqueId(obz, prefix: out);
  }

  return out;
}
