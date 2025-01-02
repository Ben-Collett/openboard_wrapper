class ColorData{
  int red;
  int green;
  int blue;
  double alpha;

  ColorData({int? red, int? green, int? blue, double? alpha}):
        red = red ?? 0,
        green = green ?? 0,
        blue = blue ?? 0,
        alpha = alpha ?? 1; 

   ColorData.fromString(String toExtract): red=0,green=0,blue=0,alpha=1 {
    List<num>? vals = extract(toExtract);

    if (vals == null || vals.length < 3) {
      throw Exception('Invalid input string');
    }

    if (vals.length >= 4 && vals[3] >= 0 && vals[3] <= 1) {
      alpha = vals[3].toDouble();  // Initialize alpha with extracted value
    } 
    red = vals[0].toInt();
    green = vals[1].toInt();
    blue = vals[2].toInt();
}

  @override 
  String toString(){
    String out = "rgb";
    if(alpha!=1){
      out += "a";
    }
    out +="($red, $green, $blue";
    if(alpha != 1){
      out += ', ${alpha.toString()}';
    }
    out+=')';
    return out;
  }
}

List<num>? extract(String text){
    if(!text.contains('(') || !text.contains(')')){
        return null;
    }

    text = text.substring(text.indexOf('(')+1);
    text = text.substring(0,text.indexOf(')'));

    List<num?> vals = text.split(',').map((s)=>num.tryParse(s.trim())).toList();
    List<num> out = vals.where((n) => n!=null).cast<num>().toList(); 

    if(vals.length != out.length){
        return null;
    }
    return out;
}

