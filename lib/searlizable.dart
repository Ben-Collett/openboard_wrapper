
import 'dart:convert';

class Searlizable {
  String toJsonString(){
    return jsonEncode(toJson());
  }
  Map<String,dynamic> toJson(){
    return {}; 
  }
}