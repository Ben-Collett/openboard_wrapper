import 'dart:convert';

mixin Searlizable {
  String toJsonString() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
