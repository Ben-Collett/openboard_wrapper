import '_utils.dart';
import 'color_data.dart';
import 'image_data.dart';
import 'searlizable.dart';
import 'sound_data.dart';
import 'obf.dart';
import 'util_classes.dart';

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
  Set<String> get jsonKeys {
    return {
      idKey,
      labelKey,
      voclizationKey,
      imageKey,
      soundKey,
      bgColorKey,
      borderColorKey,
      actionsKey,
      actionKey,
      ...extendedProperties.keys
    };
  }

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

  ///used as a fall back for loadBoardData and is useful for importing programs to avoid having to user loadBoardData directly
  Obf? linkedBoard;
  LinkedBoard? _loadBoardData;

  ///returns the loadBoardData that was set, you can invoke the updateLoadBoard to override the name, id, and path from the data in the linked board if the linked board is not null
  LinkedBoard? get loadBoardData {
    LinkedBoard? out = _loadBoardData;
    if (out == null && linkedBoard != null) {
      out = LinkedBoard.fromObf(linkedBoard!);
    }
    return out;
  }

  set loadBoardData(LinkedBoard? data) {
    _loadBoardData = data;
  }

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
      LinkedBoard? linkedBoardData,
      this.voclization})
      : extendedProperties = extendedProperties ?? {},
        _loadBoardData = linkedBoardData,
        actions = actions ?? [];

  factory ButtonData.decode(
      {required Map<String, dynamic> json,
      Map<String, ImageData>? imageSource,
      Map<String, SoundData>? soundSource}) {
    String id = json[idKey]?.toString() ?? defaultId;
    String? label = json[labelKey];
    ColorData? backgroundColor = json[bgColorKey] != null
        ? ColorData.fromString(json[bgColorKey])
        : null;
    ColorData? borderColor = json[borderColorKey] != null
        ? ColorData.fromString(json[borderColorKey])
        : null;
    String? voclization =
        json[voclizationKey] is String ? json[voclizationKey].toString() : null;
    ImageData? image;
    var imgId = json[imageKey];
    if (imgId != null && imageSource != null) {
      String imageId = imgId.toString();
      image = imageSource[imageId];
      if (image == null) {
        throw Exception('invalid image id $imgId in $imageSource');
      }
    }
    LinkedBoard? linkedBoard;
    var loadBoardVal = json['load_board'];
    if (loadBoardVal is Map) {
      linkedBoard =
          LinkedBoard.fromJson(Map<String, dynamic>.from(loadBoardVal));
    }

    SoundData? sound;
    var sndId = json[soundKey];
    if (sndId != null && soundSource != null) {
      String soundId = sndId.toString();
      sound = soundSource[soundId];
    }

    List<String> absoluteDimensionKeys = [
      AbsoluteDimensionData.leftKey,
      AbsoluteDimensionData.topKey,
      AbsoluteDimensionData.widthKey,
      AbsoluteDimensionData.heightKey
    ];
    bool hasAbsolute = false;
    for (String key in absoluteDimensionKeys) {
      if (json[key] != null) {
        hasAbsolute = true;
        break;
      }
    }

    String? action = json[actionKey];
    List<String>? actions = json[actionsKey]?.cast<String>();

    AbsoluteDimensionData? absoluteDimensionData;
    if (hasAbsolute) {
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
        linkedBoardData: linkedBoard,
        absoluteDimension: absoluteDimensionData,
        extendedProperties: getExtendedPropertiesFromJson(json));
  }

  ButtonData updateLoadBoardData() {
    if (linkedBoard == null) return this;
    LinkedBoard temp = LinkedBoard.fromObf(linkedBoard!);
    if (_loadBoardData == null) {
      _loadBoardData = temp;
      return this;
    }
    _loadBoardData?.id = temp.id;
    _loadBoardData?.name = temp.name;
    _loadBoardData?.path = temp.path;
    return this;
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
  Map<String, dynamic> toJson({bool updateLoadBoard = true}) {
    if (updateLoadBoard) {
      updateLoadBoardData();
    }
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
    if (loadBoardData != null) {
      json['load_board'] = loadBoardData?.toJson();
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
    width = (json[widthKey] as num?)?.toDouble() ?? 0;
    height = (json[heightKey] as num?)?.toDouble() ?? 0;
    left = (json[leftKey] as num?)?.toDouble() ?? 0;
    top = (json[topKey] as num?)?.toDouble() ?? 0;
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
  String? name;
  String? id;
  String? path;
  String? url;
  String? dataUrl;
  LinkedBoard({required this.name, this.id, this.path, this.url, this.dataUrl});
  LinkedBoard.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    path = json['path'];
    url = json['url'];
    dataUrl = json['data_url'];
  }
  LinkedBoard.fromObf(Obf obf)
      : name = obf.name,
        id = obf.id,
        path = obf.path;
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {'name': name};
    addToMapIfNotNull(out, 'id', id);
    addToMapIfNotNull(out, 'path', path);
    addToMapIfNotNull(out, 'url', url);
    addToMapIfNotNull(out, 'data_url', dataUrl);
    return out;
  }
}
