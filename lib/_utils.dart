
void addToMapIfNotNull(Map<String,dynamic> out, String key, dynamic value ){
  if(value != null){
    out[key]=value;
    }
  }
class InlineData{
  int encodingBase = 64;
  String data ='';
  InlineData.decode(String inline){
    String base = 'base';
    int indexOfBase = inline.indexOf(base);

    if(indexOfBase == -1){
      throw('inline data doesn\'t contain $base');
    }

    int moveForward = indexOfBase+base.length;
    inline = inline.substring(moveForward); 
    encodingBase = int.parse(inline.substring(0,inline.indexOf(',')));

    data = inline.substring(inline.indexOf(',')+1);
  }
  String encode(String dataType){
    return "data:$dataType;base$encodingBase,$data";
  }
}