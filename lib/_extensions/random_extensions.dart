import 'dart:math';

extension RandomLetter on Random {
  String nextLetter({Casing casing = Casing.random}) {
    const letterCount = 26;
    const lowerCaseAsciiOffset = 97;

    int letter = nextInt(letterCount) + lowerCaseAsciiOffset;
    String out = String.fromCharCode(letter);

    if (casing == Casing.random) {
      casing = nextBool() ? Casing.lower : Casing.upper;
    }

    if (casing == Casing.upper) {
      out = out.toUpperCase();
    }
    return out;
  }
}

enum Casing {
  random,
  lower,
  upper;
}
