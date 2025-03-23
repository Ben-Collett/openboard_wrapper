import 'package:openboard_wrapper/_utils.dart';
import 'package:openboard_wrapper/obf.dart';
import 'package:openboard_wrapper/searlizable.dart';

class SoundData extends HasIdAndPath with Searlizable {
  static const String durationKey = 'duration';
  static const String pathKey = 'path';
  static const String dataKey = 'data';
  static const String contentTypeKey = 'content_type';
  static const String urlKey = 'url';
  static const String dataUrlKey = 'data_url';
  int duration;
  @override
  String id;
  @override
  String? path;
  InlineData? data;
  String? url;
  String? dataUrl;
  String contentType;
  Map<String, dynamic> extendedProperties;
  SoundData(
      {required this.duration,
      Map<String, dynamic>? extendedProperties,
      this.id = 'defaultid',
      this.path,
      this.contentType = '',
      this.url,
      this.dataUrl,
      this.data})
      : extendedProperties = extendedProperties ?? {};
  factory SoundData.decode(Map<String, dynamic> json) {
    int duration = json[durationKey];
    String id = json[Obf.idKey] ?? '';
    String contentType = json[contentTypeKey];
    String? url = json[urlKey];
    String? dataUrl = json[dataUrlKey];
    InlineData? inline;
    if (json.containsKey(dataKey)) {
      inline = InlineData.decode(json[dataKey]);
    }
    return SoundData(
        duration: duration,
        id: id,
        contentType: contentType,
        data: inline,
        url: url,
        dataUrl: dataUrl,
        extendedProperties: getExtendedPropertiesFromJson(json));
  }
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {
      "id": id,
      durationKey: duration,
      contentTypeKey: contentType
    };
    addToMapIfNotNull(out, pathKey, path);
    addToMapIfNotNull(out, urlKey, url);
    addToMapIfNotNull(out, dataUrlKey, dataUrl);
    if (data != null) {
      out[dataKey] = data!.encode();
    }

    out.addAll(extendedProperties);
    return out;
  }
}
