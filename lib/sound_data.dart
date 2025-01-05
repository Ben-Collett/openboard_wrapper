
import 'package:openboard_searlizer/_utils.dart';
import 'package:openboard_searlizer/obf.dart';
import 'package:openboard_searlizer/searlizable.dart';

class SoundData extends Searlizable{
  static const String durationKey = 'duration';
  static const String pathKey = 'path';
  static const String dataKey = 'data';
  static const String contentTypeKey = 'content_type';
  static const String urlKey = 'url';
  int duration; 
  String id;
  String? path;
  InlineData? data;
  String? url;
  String contentType = '';
  SoundData({required this.duration, String? id, this.path, String? contentType,this.url,this.data}): id = id ?? 'default id', contentType = contentType ?? '';
  factory SoundData.decode(Map<String,dynamic> json){
    int duration = json[durationKey];
    String id = json[Obf.idKey]??'';
    String contentType  = json[contentTypeKey];
    String? url = json[urlKey];
    InlineData? inline;
    if(json.containsKey(dataKey)){
      inline = InlineData.decode(json[dataKey]);
    }
    return SoundData(duration:duration,id:id,contentType:contentType,data:inline,url:url);
  }
  @override
  Map<String, dynamic> toJson() {
    
    Map<String,dynamic> out = {"id":id,durationKey:duration,contentTypeKey:contentType};
    addToMapIfNotNull(out, pathKey, path);
    addToMapIfNotNull(out,urlKey,url);
    if(data != null){
      out[dataKey] = data?.encode(contentType);//TODO: figure otu why the ?. is beign required
    }
    return out;
  }
}