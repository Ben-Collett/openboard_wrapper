import '_utils.dart';
class ImageData {
    static const String idKey = 'id';
    static const String contentTypeKey = 'content_type';
    static const String widthKey =  'width';
    static const String heightKey = 'height';
    static const String pathKey = 'path';
    static const String inlineDataKey = 'data';

    String id = "i0";
    String contentType = '';
    int width = 0;
    int height = 0;
    
    //three ways to represent image
    String? path;
    ImageInlineData? inlineData;
    String? url;
    String? symbol;
    ImageData.decodeJson(Map<String,dynamic> json){
      id = json[idKey].toString();
      contentType = json[contentTypeKey];
      width = json[widthKey];
      height = json[heightKey];
      path = json[pathKey];
      if(json[inlineDataKey]!=null){
        inlineData = ImageInlineData.decode(json[inlineDataKey]);
      }
    } 

    Map<String,dynamic> toJson(){
     Map<String,dynamic> out = {idKey:id,widthKey:width,heightKey:height,contentTypeKey:contentType}; 
     addToMapIfNotNull(out, pathKey, path);
     addToMapIfNotNull(out,inlineDataKey,inlineData?.encode(contentType));
     return out; 
    }
    List<ImageRepresentation> getImagesInPrecedenceOrder(){
      List<ImageRepresentation> out = [];
      if(inlineData  != null){
       out.add(ImageRepresentation.inline);        
      }
      if(path != null){
        out.add(ImageRepresentation.path);
      }
      if(url != null){
       out.add(ImageRepresentation.url);
      }
      if(symbol != null){
        out.add(ImageRepresentation.symbol);
      }

      return out;
    }
   
}

class ImageInlineData{
  int encodingBase = 64;
  String data ='';
  ImageInlineData.decode(String inline){
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

  enum ImageRepresentation{
    inline,path,url,symbol
  }