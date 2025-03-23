import 'package:openboard_wrapper/searlizable.dart';

import '_utils.dart';

class ImageData extends HasIdAndPath with Searlizable {
  static const String idKey = 'id';
  static const String contentTypeKey = 'content_type';
  static const String widthKey = 'width';
  static const String heightKey = 'height';
  static const String pathKey = 'path';
  static const String inlineDataKey = 'data';
  static const String urlKey = 'url';
  static const String dataUrlKey = 'data_url';
  static const String symbolKey = 'symbol';

  @override
  String id = "i0";
  String contentType = '';
  int width = 0;
  int height = 0;
  @override
  String? path;
  InlineData? inlineData;
  String? url;
  String? dataUrl;
  Symbol? symbol;
  Map<String, dynamic> extendedProperties = {};

  ImageData(
      {Map<String, dynamic>? extendedProperties,
      String? contentType,
      String? id,
      int? width,
      int? height,
      this.path,
      this.inlineData,
      this.url,
      this.dataUrl,
      this.symbol})
      : extendedProperties = extendedProperties ?? {},
        contentType = contentType ?? '',
        id = id ?? 'i0',
        width = width ?? 0,
        height = height ?? 0;

  ImageData.decodeJson(Map<String, dynamic> json) {
    id = json[idKey].toString();
    contentType = json[contentTypeKey];
    width = json[widthKey];
    height = json[heightKey];
    path = json[pathKey];
    dataUrl = json[dataUrlKey];
    if (json[inlineDataKey] != null) {
      inlineData = InlineData.decode(json[inlineDataKey]);
    }
    url = json[urlKey];
    if (json.containsKey(symbolKey)) {
      symbol = Symbol.fromJson(json[symbolKey]);
    }
    extendedProperties = getExtendedPropertiesFromJson(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {
      idKey: id,
      widthKey: width,
      heightKey: height,
      contentTypeKey: contentType
    };

    addToMapIfNotNull(out, pathKey, path);
    addToMapIfNotNull(out, inlineDataKey, inlineData?.encode());
    addToMapIfNotNull(out, urlKey, url);
    addToMapIfNotNull(out, dataUrlKey, dataUrl);

    if (symbol != null) {
      out[symbolKey] = symbol!.toJson();
    }

    out.addAll(extendedProperties);
    return out;
  }

  List<ImageRepresentation> getImagesInPrecedenceOrder() {
    List<ImageRepresentation> out = [];
    if (inlineData != null) {
      out.add(ImageRepresentation.inline);
    }
    if (path != null) {
      out.add(ImageRepresentation.path);
    }
    if (url != null) {
      out.add(ImageRepresentation.url);
    }
    if (dataUrl != null) {
      out.add(ImageRepresentation.dataUrl);
    }
    if (symbol != null) {
      out.add(ImageRepresentation.symbol);
    }
    return out;
  }
}

class Symbol {
  static const String fileNameKey = "filename";
  static const String setKey = "set";
  String? fileName;
  String? set;
  Symbol.fromJson(Map<String, dynamic> json) {
    fileName = json[fileNameKey];
    set = json[setKey];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {};

    addToMapIfNotNull(out, fileNameKey, fileName);
    addToMapIfNotNull(out, setKey, set);

    return out;
  }
}

enum ImageRepresentation { inline, path, url, dataUrl, symbol }
