import 'package:openboard_searlizer/_utils.dart';
import 'package:test/test.dart';

void main() {
  test('auto increment test',(){
    List<String> ids = ['a','a1','a','b','b1','c','d','c1','e','a1','a2'];
    List<String> expectedIds = ['a3','a4','a','b','b1','c','d','c1','e','a1','a2'];

    List<HasId> hasIDs=ids.map((e){
      HasId id = HasId();
      id.id = e;
      return id;
    }).toList();
    List<HasId> expectedHasIDs=expectedIds.map((e){
      HasId id = HasId();
      id.id = e;
      return id;
    }).toList();
    
    autoResolveIdCollisions(hasIDs);
    
    expect(hasIDs.map((e)=>e.id),expectedHasIDs.map((e) => e.id));

  });
}