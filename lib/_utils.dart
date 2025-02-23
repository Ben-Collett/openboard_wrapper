void addToMapIfNotNull(Map<String, dynamic> out, String key, dynamic value) {
  if (value != null) {
    out[key] = value;
  }
}

class InlineData {
  int encodingBase = 64;
  String data = '';
  InlineData.decode(String inline) {
    String base = 'base';
    int indexOfBase = inline.indexOf(base);

    if (indexOfBase == -1) {
      throw ('inline data doesn\'t contain $base');
    }

    int moveForward = indexOfBase + base.length;
    inline = inline.substring(moveForward);
    encodingBase = int.parse(inline.substring(0, inline.indexOf(',')));

    data = inline.substring(inline.indexOf(',') + 1);
  }
  String encode(String dataType) {
    return "data:$dataType;base$encodingBase,$data";
  }
}

abstract class HasId {
  abstract String id;
}

abstract class HasFilePath {
  abstract String? path;
}

abstract class HasIdAndPath implements HasId, HasFilePath {
  @override
  abstract String id;
  @override
  abstract String? path;
  MapEntry<String, String>? get idMappedToPath {
    if (path == null) {
      return null;
    }
    return MapEntry(id, path!);
  }

  //MapEntry<String, String>? mapIdToPath() {}
}

Map<String, dynamic> getExtendedPropertiesFromJson(Map<String, dynamic> json) {
  Map<String, dynamic> out = {};
  for (String key in json.keys.where((k) => k.startsWith('ext_'))) {
    out[key] = json[key];
  }
  return out;
}

void autoResolveIdCollisions(Iterable<HasId> toResolve,
    {String Function(String)? onCollision}) {
  Map<String, int> frequency = idFrequency(toResolve);
  String Function(String) function = onCollision ?? _autoIncrement;
  for (HasId current in toResolve) {
    if (!frequency.containsKey(current.id)) {
      throw Exception('id: ${current.id} is not in $frequency');
    }
    //TODO: it might be wise to add a hashset that keeps track fo the seen id's in a given loop and throw an error if a duplicate or a loop appears
    while (frequency[current.id]! > 1) {
      String newId = function(current.id);
      frequency[current.id] = frequency[current.id]! - 1;
      current.id = newId;
      frequency.update(current.id, (val) => val + 1, ifAbsent: () => 1);
    }
  }
}

Map<String, int> idFrequency(Iterable<HasId> toCount) {
  Map<String, int> out = {};
  for (HasId current in toCount) {
    String id = current.id;
    out.update(id, (value) => value + 1, ifAbsent: () => 1);
  }
  return out;
}

String _autoIncrement(String val) {
  final RegExp numberPattern = RegExp(r'(\d+)$');
  final match = numberPattern.firstMatch(val);

  if (match != null) {
    final number = int.parse(match.group(0)!);
    return '${val.substring(0, val.length - match.group(0)!.length)}${(number + 1)}';
  } else {
    return '${val}1';
  }
}
