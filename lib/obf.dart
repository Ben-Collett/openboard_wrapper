import 'dart:convert';
import 'package:openboard_searlizer/_utils.dart';
import 'package:openboard_searlizer/button_data.dart';
import 'package:openboard_searlizer/image_data.dart';
import 'package:openboard_searlizer/grid_data.dart';
import 'package:openboard_searlizer/searlizable.dart';
import 'package:openboard_searlizer/sound_data.dart';
class Obf extends Searlizable{
    static const String defaultFormat = "open-board-0.1";
    static const String defaultID = "default id";
    static const String defaultLocale = "en";
    static const String defaultName = "default name";
    static const String localeKey = "locale";
    static const String nameKey = "name";
    static const String idKey = "id";
    static const String formatKey = "format";
    static const String urlKey = "url" ;
    static const String descriptionHTMLKey = "description_html";
    static const String buttonsKey = 'buttons';
    static const String imagesKey = 'images';
    static const String soundKey = 'sounds';
    String format;
    String id;
    String locale;
    String name;
    String? url;
    String? descriptionHTML;
    GridData _grid;
    List<ButtonData> buttons;
    List<ImageData> images;
    List<SoundData> sounds;
    
    Obf({this.format=defaultFormat,
    List<ButtonData>? buttons, 
    List<ImageData>?images, 
    List<SoundData>? sounds,
    GridData? grid,
    this.descriptionHTML,
    this.url,
    required this.locale,
    required this.name,
    required this.id,
    }):
    buttons = buttons??[],
    images = images ?? [],
    sounds = sounds ?? [],
    _grid = grid ?? GridData();
   
//TODO not writing sound list 
    factory Obf.fromJsonMap(Map<String,dynamic> json){
      String format = json[formatKey] is String ? json[formatKey].toString(): defaultFormat;
      String id = json[idKey] is String ? json[idKey].toString() : defaultID;
      String name = json[nameKey] is String ? json[nameKey].toString() : defaultName;
      String locale = json[localeKey] is String ? json[localeKey].toString():defaultName;
      String? descriptionHTML= json[descriptionHTMLKey] is String ? json[descriptionHTMLKey].toString() : null;
      String? url = json[urlKey] is String ? json[urlKey].toString() : null;

      List<ImageData> imageData = getImageDataFromJson(json);
      List<SoundData> soundData = getSoundDataFromJson(json);
      
      Map<String,ImageData> imageDataMap = {for(ImageData image in imageData) image.id:image};
      Map<String,SoundData> soundDataMap = {for(SoundData sound in soundData) sound.id:sound};

      List<ButtonData> buttonData = getButtonsDataFromJson(json,imageDataMap,soundDataMap);

      Map<String,ButtonData> buttonDataMap = {for(ButtonData b in buttonData) b.id:b}; 

      GridData grid = getGridDataFromJson(json, buttonDataMap);
      //TODO implement fromJsonMap for buttons and grid and images and sounds

      return Obf(format: format,id:id,locale:locale,name: name,descriptionHTML:descriptionHTML,url:url,images:imageData,sounds:soundData,buttons:buttonData,grid:grid);
    }
    static List<ImageData> getImageDataFromJson(Map<String,dynamic> json){
      var imageVals = json[imagesKey];
      List? out = [];
      if(imageVals is List){
        out = imageVals;
      }
      
      return out.map((json) => ImageData.decodeJson(json)).toList();
    }
    static List<SoundData> getSoundDataFromJson(Map<String,dynamic> json){
      var soundVals = json[soundKey];
      List? out = [];
      if(soundVals is List){
        out = soundVals;
      }
      
      return out.map((json) => SoundData.decode(json)).toList();
    }
  
    static List<ButtonData> getButtonsDataFromJson(Map<String,dynamic> json,Map<String,ImageData> imageMap, Map<String,SoundData> soundMap){
      var buttonVal = json[buttonsKey];
      List out = [];
      if(buttonVal is List){
        out = buttonVal;
      }
      
      return out.map((jsonMap) => ButtonData.decode(json: jsonMap,imageSource:imageMap,soundSource:soundMap)).toList();
    }
    static GridData getGridDataFromJson(Map<String,dynamic> json,Map<String,ButtonData> source){
      var gridData = json['grid'];
      if(gridData is Map){
        return GridData.fromStringList(orderAsStrings: gridData['order'], source: source);
      }
      return GridData();
    }
    
    @override
      String toString() {
        return super.toJsonString();
      }
    @override
    Map<String,dynamic> toJson(){
      Map<String,dynamic> out = {idKey:id,formatKey:format,localeKey:locale,nameKey:name};
      addToMapIfNotNull(out, descriptionHTMLKey, descriptionHTML);
      addToMapIfNotNull(out, urlKey, url);
      out[buttonsKey] = buttons.map((ButtonData bt) => bt.toJson()).toList();
      out['grid'] = _grid.toJson();
      out['images'] = images.map((ImageData data) => data.toJson()).toList();
      if(sounds.isNotEmpty){
        print('l');
      }
      out['sounds'] = sounds.map((SoundData data) => data.toJson()).toList();
         
      return out;
    }

    factory Obf.fromJsonString(String json){
      return Obf.fromJsonMap(jsonDecode(json));
    }

    //add's button to list of buttons and adds to grid if row and col are specified
    bool setButton({ButtonData? button, int? row, int? col}){
      if(button != null &&!buttons.contains(button)){
        addButton(button);
      }
      if(row != null && col!= null){
        _grid[row][col] = button;
      }
      return true;
    }
    void addButton(ButtonData button){
      //TODO: I need to make this handle if new audio and images are introduced in button
      buttons.add(button); 
    }
    ButtonData? getButton(int row, int col){
      return _grid[row][col];
    }
    bool addImage(ImageData imageData){
      return true;
    }
    bool addSound(SoundData soundData){
      return true;
    }
    bool removeButton(ButtonData button){
      return false;
    }
    void addRow(ButtonData buttons){
      
    }
    void addCol(){
      
    }



   
}

