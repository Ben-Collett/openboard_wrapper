
import 'package:openboard_searlizer/searlizable.dart';

class SoundData extends Searlizable{
  int duration; 
  String id;
  String? path;
  String contentType = '';
  SoundData({required this.duration, String? id, this.path, String?  contentType}): id = id ?? 'default id', contentType = contentType ?? '';
  @override
  Map<String, dynamic> toJson() {
    
    Map<String,dynamic> out = {"id":id,"duration":duration,"contentType":contentType};
    return out;
  }
}