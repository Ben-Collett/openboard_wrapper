import 'package:openboard_parser/button_data.dart';
import 'package:openboard_parser/image_data.dart';
import 'package:openboard_parser/grid_data.dart';

class Obf {
    String format;
    int id;
    String local;
    String name;
    String? url;
    String? descrpitionHTML;
    GridData? grid;
    ButtonData? buttons;
    ImagesData? images;
    Obf({this.format="open-board-0.1",this.id=1,required this.local,required this.name});
    factory Obf.fromJsonMap(Map<String,Object> json){
        return Obf(local: "en",name: "hi");
    }
    factory Obf.fromJsonString(String json){
        return Obf(local: "en",name: "hi");
    }
    factory Obf.fromFile(String path){
        return Obf(local: "en",name: "hi");
    }
}