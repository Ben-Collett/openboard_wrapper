import 'package:openboard_searlizer/_utils.dart';
import 'package:openboard_searlizer/color_data.dart';
import 'package:openboard_searlizer/image_data.dart';
import 'package:openboard_searlizer/searlizable.dart';
import 'package:openboard_searlizer/sound_data.dart';
class ButtonData extends Searlizable{
    static const String idKey = "id";
    static const String labelKey = "label";
    static const String imageKey = "image_id";
    static const String soundKey = 'sound_id';
    static const String bgColorKey = "background_color";
    static const String borderColorKey = 'border_color';
    static const String defultId = 'default id';
    String id;
    String? label;
    ImageData? image;
    SoundData? sound;
    ColorData? backgroundColor;
    ColorData? borderColor;
    ButtonData({this.id=defultId,this.label,this.image,this.sound,this.backgroundColor,this.borderColor});

    
    factory ButtonData.decode({required Map<String,dynamic> json,Map<String,ImageData>? imageSource, Map<String,SoundData>? soundSource}){
    String id = json[idKey]?.toString() ?? defultId ;  
    String label = json[labelKey];
    ColorData? backgroundColor = json[bgColorKey]!= null ? ColorData.fromString(json[bgColorKey]): null;   
    ColorData? borderColor = json[borderColorKey]!= null ? ColorData.fromString(json[borderColorKey]): null;   
    
    ImageData? image;
    if(json.containsKey(imageKey)&&imageSource != null){
      String imageId = json[imageKey].toString();
      if(imageSource.containsKey(imageId)){
        image = imageSource[imageId];
      }
      else{
        throw Exception('invalid image id ${json[imageKey]} in $imageSource');
      }
    }
    
    SoundData? sound;
    if(json.containsKey(soundKey)&& soundSource != null){
      String soundId = json[soundKey].toString();
      if(soundSource.containsKey(soundId)){
        sound = soundSource[soundId];
      }
    }

    return ButtonData(id:id,label:label,backgroundColor:backgroundColor,image:image,borderColor:borderColor,sound:sound);
   } 
    @override 
    Map<String,dynamic> toJson(){
      Map<String,dynamic>json = {idKey:id};
      addToMapIfNotNull(json,bgColorKey,backgroundColor?.toString());
      addToMapIfNotNull(json,borderColorKey,borderColor?.toString());
      addToMapIfNotNull(json, labelKey, label); 
      //TODO: finish this after I can encodee images, sound's  
      addToMapIfNotNull(json,imageKey,image?.id);
      addToMapIfNotNull(json,soundKey,sound?.id);
      return json; 
    }

    bool safeSetImage(ImageData data,List<ImageData> imagesFromObf){
      
      return true;
    }
    void unsafeSetImage(ImageData data){
      this.image = data;
    }
}