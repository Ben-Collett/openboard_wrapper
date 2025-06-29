import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:openboard_wrapper/_utils.dart';
import 'package:openboard_wrapper/button_data.dart';
import 'package:openboard_wrapper/image_data.dart';
import 'package:openboard_wrapper/grid_data.dart';
import 'package:openboard_wrapper/license_data.dart';
import 'package:openboard_wrapper/obz.dart';
import 'package:openboard_wrapper/searlizable.dart';
import 'package:openboard_wrapper/sound_data.dart';

class Obf extends HasIdAndPath with Searlizable {
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
  Set<String> get jsonKeys {
    return {
      localeKey,
      'strings',
      nameKey,
      idKey,
      formatKey,
      urlKey,
      descriptionHTMLKey,
      buttonsKey,
      imagesKey,
      soundKey,
      ...extendedProperties.keys,
    };
  }

  String format;
  @override
  String id;
  String locale;
  String name;
  String? url;
  String? descriptionHTML;
  LicenseData? licenseData;
  late GridData grid;
  late List<ButtonData> buttons;
  List<ImageData> _images;
  @override
  String? path;

  Map<String, Map<String, String>> _localeStrings;
  List<ImageData> get images {
    List<ImageData> temp = List.of(_images);
    temp.addAll(buttons.map((b) => b.image).nonNulls.toList());
    return temp.toSet().toList();
  }

  List<SoundData> _sounds;
  List<SoundData> get sounds {
    List<SoundData> temp = List.of(_sounds);
    temp.addAll(buttons.map((b) => b.sound).nonNulls.toList());
    return temp.toSet().toList();
  }

  Map<String, dynamic> extendedProperties;
  UnmodifiableSetView<String> get allExtendedPropertiesInFile {
    Set<String> out = Set.of(extendedProperties.keys);
    for (ButtonData button in buttons) {
      out.addAll(button.extendedProperties.keys);
    }
    for (ImageData image in images) {
      out.addAll(image.extendedProperties.keys);
    }
    for (SoundData sound in sounds) {
      out.addAll(sound.extendedProperties.keys);
    }
    return UnmodifiableSetView(out);
  }

  Obf({
    this.format = defaultFormat,
    List<ButtonData>? buttons,
    List<ImageData>? images,
    List<SoundData>? sounds,
    GridData? grid,
    Map<String, Map<String, String>>? localeStrings,
    Map<String, dynamic>? extendedProperties,
    this.descriptionHTML,
    this.licenseData,
    this.url,
    this.path,
    required this.locale,
    required this.name,
    required this.id,
  })  : buttons = buttons ?? [],
        _sounds = sounds ?? [],
        grid = grid ?? GridData(),
        extendedProperties = extendedProperties ?? {},
        _images = images ?? [],
        _localeStrings = localeStrings ?? {};

  Obf.fromFile(File file) : this.fromJsonString(file.readAsStringSync());

  Obf.fromJsonMap(Map<String, dynamic> json)
      : _localeStrings = _parseLocaleStrings(json),
        _sounds = getSoundDataFromJson(json),
        extendedProperties = getExtendedPropertiesFromJson(json),
        format = _isStringElse(json[formatKey], defaultFormat),
        id = _isStringElse(json[idKey], defaultID),
        name = _isStringElse(json[nameKey], defaultName),
        locale = _isStringElse(json[localeKey], defaultLocale),
        descriptionHTML = _isStringElseNull(json[descriptionHTMLKey]),
        url = _isStringElseNull(json[urlKey]),
        licenseData = _parseLicenseData(json),
        _images = getImageDataFromJson(json) {
    Map<String, ImageData> imageDataMap = {
      for (ImageData image in _images) image.id: image
    };
    Map<String, SoundData> soundDataMap = {
      for (SoundData sound in _sounds) sound.id: sound
    };

    buttons = getButtonsDataFromJson(json, imageDataMap, soundDataMap);

    Map<String, ButtonData> buttonDataMap = {
      for (ButtonData b in buttons) b.id: b
    };

    grid = getGridDataFromJson(json, buttonDataMap);
  }
  static String _isStringElse(dynamic val, String defaultValue) {
    return val is String ? val : defaultValue;
  }

  static String? _isStringElseNull(dynamic val) {
    return val is String ? val : null;
  }

  static LicenseData? _parseLicenseData(Map<String, dynamic> json) {
    return json[licenseKey] is Map
        ? LicenseData.fromJson(json[licenseKey])
        : null;
  }

  static Map<String, Map<String, String>> _parseLocaleStrings(
      Map<String, dynamic> json) {
    Map<String, Map<String, String>> localeStrings = {};
    if (json.containsKey('strings') && json['strings'] is Map) {
      for (var entry in json['strings'].entries) {
        if (entry.value is Map) {
          String locale = entry.key;
          localeStrings[locale] = {};
          for (var nestedEntry in entry.value.entries) {
            String wordInDefaultLocale = nestedEntry.key;
            String wordInLocale = nestedEntry.value;
            localeStrings[locale]![wordInDefaultLocale] = wordInLocale;
          }
        }
      }
    }
    return localeStrings;
  }

  Obf addImage(ImageData image) {
    _images.add(image);
    return this;
  }

  Obf addSound(SoundData sound) {
    _sounds.add(sound);
    return this;
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

  Obf addWordInLocale(
      {required String locale,
      required String wordInDefaultLocal,
      required String wordInLocale}) {
    _localeStrings.putIfAbsent(locale, () => {})[wordInDefaultLocal] =
        wordInLocale;
    return this;
  }

  Obf removeWordInLocaleFromDefault(
      {required String locale, required String wordInDefaultLocale}) {
    _localeStrings[locale]?.remove(wordInDefaultLocale);
    return this;
  }

  Obf removeWordInLocaleFromWordInLocale(
      {required String locale, required String wordInlocale}) {
    _localeStrings[locale]?.removeWhere((key, value) => value == wordInlocale);
    return this;
  }

  Obf removeWordInLocaleFromDefaultLocale(
      {required String word, required String locale}) {
    _localeStrings[locale]?.removeWhere((key, value) => key == word);
    return this;
  }

  ButtonData? findButtonById(String id) {
    return buttons.where((b) => b.id == id).firstOrNull;
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
    out.addAll(extendedProperties);

    out[buttonsKey] = buttons.map((ButtonData bt) => bt.toJson()).toList();
    out['grid'] = grid.toJson();
    if (_localeStrings.isNotEmpty) {
      out['strings'] = _localeStrings;
    }

    out['images'] = images.map((ImageData data) => data.toJson()).toList();
    out['sounds'] = sounds.map((SoundData data) => data.toJson()).toList();

    return out;
  }

  ///Converts a single obf into an obz with just that board which is set as the root board.
  Obz toSimpleObz() {
    Obz obz = Obz(root: this);
    return obz;
  }

  Obf.fromJsonString(String json) : this.fromJsonMap(jsonDecode(json));
}
