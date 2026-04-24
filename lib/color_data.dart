abstract mixin class ColorData {
  int get red;
  int get green;
  int get blue;
  double get alpha;

  @override
  String toString() {
    String out = "rgb";
    if (alpha != 1) {
      out += "a";
    }
    out += "($red, $green, $blue";
    if (alpha != 1) {
      out += ', ${alpha.toString()}';
    }
    out += ')';
    return out;
  }

  PooledColorData asPooled();
  MutableColorData asMutable();

  static ColorData fromString(String toExtract) {
    List<num>? vals = extract(toExtract);
    if (vals == null || vals.length < 3) {
      throw Exception('Invalid input string');
    }
    double alpha = 1.0;
    if (vals.length >= 4 && vals[3] >= 0 && vals[3] <= 1) {
      alpha = vals[3].toDouble();
    }
    return PooledColorData(
      red: vals[0].toInt(),
      green: vals[1].toInt(),
      blue: vals[2].toInt(),
      alpha: alpha,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ColorData &&
        red == other.red &&
        green == other.green &&
        blue == other.blue &&
        alpha == other.alpha;
  }

  @override
  int get hashCode => Object.hash(red, green, blue, alpha);
}

class MutableColorData with ColorData {
  @override
  int red;
  @override
  int green;
  @override
  int blue;
  @override
  double alpha;

  MutableColorData({int? red, int? green, int? blue, double? alpha})
      : red = red ?? 0,
        green = green ?? 0,
        blue = blue ?? 0,
        alpha = alpha ?? 1.0;

  factory MutableColorData.fromString(String s) {
    List<num>? vals = extract(s);
    if (vals == null || vals.length < 3) {
      throw Exception('Invalid input string');
    }
    int red = vals[0].toInt();
    int green = vals[1].toInt();
    int blue = vals[2].toInt();
    double alpha = 1.0;
    if (vals.length >= 4 && vals[3] >= 0 && vals[3] <= 1) {
      alpha = vals[3].toDouble();
    }
    return MutableColorData(red: red, green: green, blue: blue, alpha: alpha);
  }

  @override
  PooledColorData asPooled() =>
      PooledColorData(red: red, green: green, blue: blue, alpha: alpha);

  @override
  MutableColorData asMutable() => this;
}

class PooledColorData with ColorData {
  @override
  final int red;
  @override
  final int green;
  @override
  final int blue;
  @override
  final double alpha;

  static final Map<String, WeakReference<PooledColorData>> _pool = {};

  PooledColorData._(this.red, this.green, this.blue, this.alpha);

  factory PooledColorData(
      {int red = 0, int green = 0, int blue = 0, double alpha = 1.0}) {
    final key = '$red,$green,$blue,$alpha';
    final weakRef = _pool[key];
    if (weakRef != null) {
      final existing = weakRef.target;
      if (existing != null) {
        return existing;
      }
    }
    final newInstance = PooledColorData._(red, green, blue, alpha);
    _pool[key] = WeakReference(newInstance);
    return newInstance;
  }

  static void cleanPool() {
    _pool.removeWhere((key, weakRef) => weakRef.target == null);
  }

  @override
  PooledColorData asPooled() => this;

  @override
  MutableColorData asMutable() =>
      MutableColorData(red: red, green: green, blue: blue, alpha: alpha);
}

List<num>? extract(String text) {
  if (!text.contains('(') || !text.contains(')')) {
    return null;
  }

  text = text.substring(text.indexOf('(') + 1);
  text = text.substring(0, text.indexOf(')'));

  List<num?> vals = text.split(',').map((s) => num.tryParse(s.trim())).toList();
  List<num> out = vals.where((n) => n != null).cast<num>().toList();

  if (vals.length != out.length) {
    return null;
  }
  return out;
}
