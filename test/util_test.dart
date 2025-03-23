import 'package:openboard_wrapper/_utils.dart';
import 'package:test/test.dart';

void main() {
  test('auto increment test', () {
    List<String> ids = [
      'a',
      'a1',
      'a',
      'b',
      'b1',
      'c',
      'd',
      'c1',
      'e',
      'a1',
      'a2'
    ];
    List<String> expectedIds = [
      'a3',
      'a4',
      'a',
      'b',
      'b1',
      'c',
      'd',
      'c1',
      'e',
      'a1',
      'a2'
    ];

    List<HasId> hasIDs = ids.map((e) {
      HasId id = HasIdImp();
      id.id = e;
      return id;
    }).toList();
    List<HasId> expectedHasIDs = expectedIds.map((e) {
      HasId id = HasIdImp();
      id.id = e;
      return id;
    }).toList();

    autoResolveIdCollisions(hasIDs);

    expect(hasIDs.map((e) => e.id), expectedHasIDs.map((e) => e.id));
  });

  const String inlineData = 'data:image/png;base32,THISISDATA';
  test('decode inline data test', () {
    InlineData inline = InlineData.decode(inlineData);
    expect(inline.data, 'THISISDATA');
    expect(inline.encodingBase, 32);
    expect(inline.dataType, 'image/png');
  });
  test('encode inline data', () {
    InlineData inline = InlineData(
      dataType: 'image/png',
      encodingBase: 32,
      data: 'THISISDATA',
    );

    expect(inline.encode(), inlineData);
  });
}

class HasIdImp extends HasId {
  @override
  String id = '';
}
