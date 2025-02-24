import 'package:openboard_wrapper/_utils.dart';
import 'package:openboard_wrapper/color_data.dart';
import 'package:openboard_wrapper/image_data.dart';
import 'package:openboard_wrapper/searlizable.dart';
import 'package:openboard_wrapper/sound_data.dart';
import 'package:openboard_wrapper/obf.dart';

class ButtonData with Searlizable implements HasId {
  static const String idKey = "id";
  static const String labelKey = "label";
  static const String voclizationKey = 'voclization';
  static const String imageKey = "image_id";
  static const String soundKey = 'sound_id';
  static const String bgColorKey = "background_color";
  static const String borderColorKey = 'border_color';
  static const String defaultId = 'default id';
  static const String actionKey = 'action';
  static const String actionsKey = 'actions';
  @override
  String id;
  String? label;
  String? voclization;
  ImageData? image;
  SoundData? sound;
  ColorData? backgroundColor;
  ColorData? borderColor;
  AbsoluteDimensionData? absoluteDimension;
  Map<String, dynamic> extendedProperties;
  String? action;
  List<String> actions;
  Obf? linkedBoard;

  ButtonData(
      {this.id = defaultId,
      List<String>? actions,
      Map<String, dynamic>? extendedProperties,
      this.label,
      this.image,
      this.sound,
      this.backgroundColor,
      this.borderColor,
      this.absoluteDimension,
      this.action,
      this.linkedBoard,
      this.voclization})
      : extendedProperties = extendedProperties ?? {},
        actions = actions ?? [];

  factory ButtonData.decode(
      {required Map<String, dynamic> json,
      Map<String, ImageData>? imageSource,
      Map<String, SoundData>? soundSource}) {
    String id = json[idKey]?.toString() ?? defaultId;
    String label = json[labelKey];
    ColorData? backgroundColor = json[bgColorKey] != null
        ? ColorData.fromString(json[bgColorKey])
        : null;
    ColorData? borderColor = json[borderColorKey] != null
        ? ColorData.fromString(json[borderColorKey])
        : null;
    String? voclization =
        json[voclizationKey] is String ? json[voclizationKey].toString() : null;
    ImageData? image;
    if (json.containsKey(imageKey) && imageSource != null) {
      String imageId = json[imageKey].toString();
      if (imageSource.containsKey(imageId)) {
        image = imageSource[imageId];
      } else {
        throw Exception('invalid image id ${json[imageKey]} in $imageSource');
      }
    }

    SoundData? sound;
    if (json.containsKey(soundKey) && soundSource != null) {
      String soundId = json[soundKey].toString();
      if (soundSource.containsKey(soundId)) {
        sound = soundSource[soundId];
      }
    }

    List<String> absoluteDimensionKeys = [
      AbsoluteDimensionData.leftKey,
      AbsoluteDimensionData.topKey,
      AbsoluteDimensionData.widthKey,
      AbsoluteDimensionData.heightKey
    ];
    Map<String, dynamic> absoluteJson = {};
    for (String key in absoluteDimensionKeys) {
      if (json[key] != null) {
        absoluteJson[key] = json[key];
      }
    }

    String? action = json[actionKey];
    List<String>? actions = json[actionsKey]?.cast<String>();

    AbsoluteDimensionData? absoluteDimensionData;
    if (absoluteJson.isNotEmpty) {
      absoluteDimensionData = AbsoluteDimensionData.fromJson(json);
    }
    return ButtonData(
        id: id,
        label: label,
        voclization: voclization,
        backgroundColor: backgroundColor,
        image: image,
        borderColor: borderColor,
        sound: sound,
        action: action,
        actions: actions,
        absoluteDimension: absoluteDimensionData,
        extendedProperties: getExtendedPropertiesFromJson(json));
  }
  ButtonData addAction(String action) {
    actions.add(action);
    return this;
  }

  ButtonData addActionFromPredefined(PredefinedSpecialtyAction action) {
    actions.add(action.asString);
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {idKey: id};
    addToMapIfNotNull(json, bgColorKey, backgroundColor?.toString());
    addToMapIfNotNull(json, borderColorKey, borderColor?.toString());
    addToMapIfNotNull(json, labelKey, label);
    addToMapIfNotNull(json, imageKey, image?.id);
    addToMapIfNotNull(json, soundKey, sound?.id);
    addToMapIfNotNull(json, voclizationKey, voclization);
    addToMapIfNotNull(json, actionKey, action);

    json.addAll(absoluteDimension?.toJson() ?? {});
    json.addAll(extendedProperties);

    if (actions.isNotEmpty) {
      json[actionsKey] = actions;
    }

    return json;
  }
}

enum PredefinedSpecialtyAction {
  backSpace(':backspace'),
  space(':space'),
  clear(':clear'),
  appendSomething('+something'),
  home(':home'),
  speak(':speak');

  final String asString;
  const PredefinedSpecialtyAction(this.asString);
}

class AbsoluteDimensionData with Searlizable {
  static const String widthKey = 'width';
  static const String heightKey = 'height';
  static const String leftKey = 'left';
  static const String topKey = 'top';
  double _width = 0;
  set width(double width) {
    if (width < 0 || width > 1) {
      throw Exception('width has to be between 0 and 1, not: $width');
    }
    _width = width;
  }

  double get width => _width;
  double _height = 0;
  set height(double height) {
    if (height < 0 || height > 1) {
      throw Exception('height has to be between 0 and 1, not $height');
    }
    _height = height;
  }

  double get height => _height;
  double _top = 0;
  set top(double top) {
    if (top < 0 || top > 1) {
      throw Exception('top has to be between 0 and 1, not $top');
    }
    _top = top;
  }

  double get top => _top;
  double _left = 0;
  set left(double left) {
    if (left < 0 || left > 1) {
      throw Exception('left has to be between 0 and 1, not $left');
    }
    _left = left;
  }

  double get left => _left;

  AbsoluteDimensionData(
      {double width = 0, double height = 0, double left = 0, double top = 0}) {
    height = height;
    width = width;
    left = left;
    top = top;
  }
  AbsoluteDimensionData.fromJson(Map<String, dynamic> json) {
    //has to handle edge case of an int 1 or 0 being passed instead of a double, to do so convert to string then parse to num then convert to double.
    width = json[widthKey] is num
        ? num.parse(json[widthKey].toString()).toDouble()
        : 0;
    height = json[heightKey] is num
        ? num.parse(json[heightKey].toString()).toDouble()
        : 0;
    left = json[leftKey] is num
        ? num.parse(json[leftKey].toString()).toDouble()
        : 0;
    top =
        json[topKey] is num ? num.parse(json[topKey].toString()).toDouble() : 0;
  }
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    addToMapIfNotNull(json, widthKey, width);
    addToMapIfNotNull(json, heightKey, height);
    addToMapIfNotNull(json, leftKey, left);
    addToMapIfNotNull(json, topKey, top);

    return json;
  }
}

class LinkedBoard {
  String name;
  String? path;
  String? url;
  String? dataUrl;
  LinkedBoard({required this.name, this.path, this.url, this.dataUrl});
}
