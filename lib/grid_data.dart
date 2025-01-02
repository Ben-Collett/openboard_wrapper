import 'package:openboard_searlizer/button_data.dart';
import 'package:openboard_searlizer/searlizable.dart';
class GridData extends Searlizable{
  List<List<ButtonData?>> _order;
  int get rows => _order.length;
  int get columns => _order.isEmpty ? 0 : _order[0].length;
  GridData({List<List<ButtonData?>>? order}) : _order = order??[];
  factory GridData.fromStringList({required List<dynamic>? orderAsStrings, required Map<String,ButtonData> source}){
    if(orderAsStrings== null || orderAsStrings.isEmpty){
      return GridData();
    } 
    List<List<String?>> extracted = [];
    for(dynamic list in orderAsStrings){
      if(list is List){
        extracted.add([]);
        for(var value in list){
          extracted.last.add(value?.toString());
        }
      }
    }

    List<List<ButtonData?>> order = [];
    for(List<String?> list in extracted){
      order.add([]);
      for(String? current in list){
        if(current == null){
           order.last.add(null); 
        }
        else if(source.containsKey(current)){
          order.last.add(source[current]);          
        }
        else{
          throw ArgumentError('order contains a key $current which is not null and does not exist as a key in the  source ${source.keys}');
        }
      }
    }
         
    return GridData(order:order);
  }
  @override
  Map<String,dynamic> toJson(){
   Map<String,dynamic> out = {'rows':rows,'columns':columns};
   List<List<String?>> idOrder = [];
   for(List<ButtonData?> row in _order){
      idOrder.add(row.map((bt)=>bt?.id).toList()); 
    } 
    out['order']= idOrder;
    return out;

  }
  
  void addRow(){

  }
  void addCol(){

  }
  void setButton({required int row, required int col, ButtonData? button}){

  }
  List<ButtonData?> operator [](int row) {
    return _order[row];
  }
}