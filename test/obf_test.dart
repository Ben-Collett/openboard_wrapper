import 'dart:convert';

import 'package:test/test.dart';
import 'package:openboard_searlizer/obf.dart';
import './test_boards/board_strings.dart';
void main(){
  test('simple board to json',(){
    
    expect(Obf.fromJsonString(simpleBoard).toJson(),jsonDecode(simpleBoard)); 

  });
  test('simble board with errors json',(){
    expect(Obf.fromJsonString(simpleBoardWithErrors).toJson(),jsonDecode(simpleBoard)); 
  });
  test('inline data',(){
    expect(Obf.fromJsonString(inlineImages).toJson(),jsonDecode(inlineImages));
  });
  test('url image', (){
    expect(Obf.fromJsonString(urlImage).toJson(),jsonDecode(urlImage));
  });
}

  Obf getSimpleBoard(){
    return Obf.fromJsonString(simpleBoard);
  }