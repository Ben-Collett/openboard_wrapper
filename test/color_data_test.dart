
import 'package:openboard_searlizer/color_data.dart';
import 'package:test/test.dart';

void main() {
  test('parse extract RGB', () {
    String input = 'RGB(234,111,30)';
    List<int> expected = [234,111,30];
    expect(extract(input), expected);
  });
  test('parse extract RGBA',(){
    String input = 'RGBA(234,111,30,.3)';
    List<num> expected = [234,111,30,.3];
    expect(extract(input), expected);
  });
  test('RGB to string',(){
    String expected = 'RGB(2,11,30)';
    ColorData data = ColorData(red:2,green:11,blue:30); 
    expect(data.toString(), expected);
  });
  test('RGBA to string',(){
    String expected = 'RGBA(234,111,30,0.3)';
    ColorData data = ColorData(red:234,green:111,blue:30,alpha:.3); 
    expect(data.toString(), expected);
  });
}