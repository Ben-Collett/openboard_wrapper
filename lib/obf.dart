import 'dart:convert';
import 'package:openboard_searlizer/_utils.dart';
import 'package:openboard_searlizer/button_data.dart';
import 'package:openboard_searlizer/image_data.dart';
import 'package:openboard_searlizer/grid_data.dart';
import 'package:openboard_searlizer/license_data.dart';
import 'package:openboard_searlizer/searlizable.dart';
import 'package:openboard_searlizer/sound_data.dart';

class Obf extends Searlizable implements HasId {
  static const defaultFormat = "open-board-0.1";
  static const defaultID = "default id";
  static const defaultLocale = "en";
  static const defaultName = "default name";
  static const localeKey = "locale";
  static const nameKey = "name";
  static const idKey = "id";
  static const formatKey = "format";
  static const licenseKey = 'license';
  static const urlKey = "url";
  static const descriptionHTMLKey = "description_html";
  static const buttonsKey = 'buttons';
  static const imagesKey = 'images';
  static const soundKey = 'sounds';
  String format;
  @override
  String id;
  String locale;
  String name;
  String? url;
  String? descriptionHTML;
  LicenseData? licenseData;
  GridData _grid;
  List<ButtonData> buttons;
  List<ImageData> _images;
  List<ImageData> get images {
    List<ImageData> temp = buttons.map((b) => b.image).nonNulls.toList();
    temp.addAll(_images);
    return temp.toSet().toList();
  }

  List<SoundData> sounds;
  Map<String, dynamic> extendedProperties;
  Set<String>? allExtendedPropertiesInFile;
  Obf({
    this.format = defaultFormat,
    List<ButtonData>? buttons,
    List<ImageData>? images,
    List<SoundData>? sounds,
    GridData? grid,
    Map<String, dynamic>? extendedProperties,
    this.descriptionHTML,
    this.licenseData,
    this.url,
    required this.locale,
    required this.name,
    required this.id,
  })  : buttons = buttons ?? [],
        sounds = sounds ?? [],
        _grid = grid ?? GridData(),
        extendedProperties = extendedProperties ?? {},
        _images = images ?? [];

  factory Obf.fromJsonMap(Map<String, dynamic> json) {
    String format =
        json[formatKey] is String ? json[formatKey].toString() : defaultFormat;
    String id = json[idKey] is String ? json[idKey].toString() : defaultID;
    String name =
        json[nameKey] is String ? json[nameKey].toString() : defaultName;
    String locale =
        json[localeKey] is String ? json[localeKey].toString() : defaultName;
    String? descriptionHTML = json[descriptionHTMLKey] is String
        ? json[descriptionHTMLKey].toString()
        : null;
    String? url = json[urlKey] is String ? json[urlKey].toString() : null;
    LicenseData? licenseData =
        json[licenseKey] is Map ? LicenseData.fromJson(json[licenseKey]) : null;
    List<ImageData> imageData = getImageDataFromJson(json);
    List<SoundData> soundData = getSoundDataFromJson(json);

    Map<String, ImageData> imageDataMap = {
      for (ImageData image in imageData) image.id: image
    };
    Map<String, SoundData> soundDataMap = {
      for (SoundData sound in soundData) sound.id: sound
    };

    List<ButtonData> buttonData =
        getButtonsDataFromJson(json, imageDataMap, soundDataMap);

    Map<String, ButtonData> buttonDataMap = {
      for (ButtonData b in buttonData) b.id: b
    };

    GridData grid = getGridDataFromJson(json, buttonDataMap);

    return Obf(
        format: format,
        id: id,
        locale: locale,
        name: name,
        descriptionHTML: descriptionHTML,
        url: url,
        images: imageData,
        sounds: soundData,
        buttons: buttonData,
        grid: grid,
        licenseData: licenseData,
        extendedProperties: getExtendedPropertiesFromJson(json));
  }

  static List<ImageData> getImageDataFromJson(Map<String, dynamic> json) {
    var imageVals = json[imagesKey];
    List? out = [];
    if (imageVals is List) {
      out = imageVals;
    }

    return out.map((json) => ImageData.decodeJson(json)).toList();
  }

  static List<SoundData> getSoundDataFromJson(Map<String, dynamic> json) {
    var soundVals = json[soundKey];
    List? out = [];
    if (soundVals is List) {
      out = soundVals;
    }

    return out.map((json) => SoundData.decode(json)).toList();
  }

  static List<ButtonData> getButtonsDataFromJson(Map<String, dynamic> json,
      Map<String, ImageData> imageMap, Map<String, SoundData> soundMap) {
    var buttonVal = json[buttonsKey];
    List out = [];
    if (buttonVal is List) {
      out = buttonVal;
    }

    return out
        .map((jsonMap) => ButtonData.decode(
            json: jsonMap, imageSource: imageMap, soundSource: soundMap))
        .toList();
  }

  static GridData getGridDataFromJson(
      Map<String, dynamic> json, Map<String, ButtonData> source) {
    var gridData = json['grid'];
    if (gridData is Map) {
      return GridData.fromStringList(
          orderAsStrings: gridData['order'], source: source);
    }
    return GridData();
  }

  Obf autoResolveAllIdCollisionsInFile({String Function(String)? onCollision}) {
    autoResolveIdCollisions(_allHasIdsInFile(), onCollision: onCollision);
    return this;
  }

  List<HasId> _allHasIdsInFile() {
    List<HasId> ids = [this];
    ids.addAll(buttons);
    ids.addAll(images);
    ids.addAll(sounds);
    return ids;
  }

  @override
  String toString() {
    return super.toJsonString();
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {
      idKey: id,
      formatKey: format,
      localeKey: locale,
      nameKey: name
    };

    addToMapIfNotNull(out, descriptionHTMLKey, descriptionHTML);
    addToMapIfNotNull(out, urlKey, url);

    addToMapIfNotNull(out, licenseKey, licenseData?.toJson());

    out[buttonsKey] = buttons.map((ButtonData bt) => bt.toJson()).toList();
    out['grid'] = _grid.toJson();
    out['images'] = images.map((ImageData data) => data.toJson()).toList();
    out['sounds'] = sounds.map((SoundData data) => data.toJson()).toList();

    out.addAll(extendedProperties);
    return out;
  }

  factory Obf.fromJsonString(String json) {
    return Obf.fromJsonMap(jsonDecode(json));
  }
}
