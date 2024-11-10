abstract class ColorData {
    ColorData? decode(String jsonPart){
        if(jsonPart.contains("RGBA")){ 
            List<num> vals = extract(jsonPart) ?? List.empty();
            if(vals.length<4){
                return null;
            }
            int red = vals[0].toInt();
            int green = vals[1].toInt();
            int blue = vals[2].toInt();
            double alpha = vals[3].toDouble(); 
        }
        else if(jsonPart.contains("RGB")){
            int red,green,blue;
        }
    }
}
List<int>? extractRGB(List<num> nums){
    return null; 
}
List<int>? extractA(List<num> nums){
    return null;
}
List<num>? extract(String text){
    if(!text.contains('(') || !text.contains(')')){
        return null;
    }

    text = text.substring(text.indexOf('(')+1);
    text = text.substring(0,text.indexOf(')')-1);

    List<num?> vals = text.split(',').map((s)=>num.tryParse(s.trim())).toList();
    List<num> out = vals.where((n) => n!=null).cast<num>().toList(); 

    if(vals.length != out.length){
        return null;
    }
    return out;
}

class RGBA extends ColorData {
  int red;
  int green;
  int blue;
  double alpha;

  RGBA({this.red = 0, this.green = 0, this.blue = 0, this.alpha = 1});
  
  String encode(){
   return "RGBA($red, $blue, $green, $alpha)"; 
  }
}

class RGB extends RGBA {
  RGB({super.red, super.green, super.blue}):super(alpha: 1);

   @override
   String encode(){
   return "RGB($red, $blue, $green)"; 
  }
}