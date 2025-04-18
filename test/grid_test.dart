import 'package:openboard_wrapper/button_data.dart';
import 'package:openboard_wrapper/grid_data.dart';
import 'package:test/test.dart';

final ButtonData b1 = ButtonData(id: 'b1', label: 'hi');
final ButtonData b2 = ButtonData(id: 'b2', label: 'bye');
final b3 = ButtonData(id: 'b3', label: 'weird');

void main() {
  test('insert column middle', () {
    var expected = [
      [b1, null, b2],
      [null, null, null]
    ];
    expect(order(getSimpleGrid().insertColumnAt(1)), expected);
  });
  test('insert row middle', () {
    var expected = [
      [b1, b2],
      [null, null],
      [b3, null]
    ];
    expect(
        order(getSimpleGrid()
            .setButtonData(row: 1, col: 0, data: b3)
            .insertRowAt(1)),
        expected);
  });
  test('add row bottom', () {
    var expected = [
      [b1, b2],
      [null, null],
      [null, null]
    ];
    expect(order(getSimpleGrid().addRowToTheBottom()), expected);
  });
  test('add column right', () {
    var expected = [
      [b1, b2, null],
      [null, null, null]
    ];
    expect(order(getSimpleGrid().addColumnToTheRight()), expected);
  });
  test('add column left', () {
    var expected = [
      [null, b1, b2],
      [null, null, null]
    ];
    return expect(order(getSimpleGrid().addColumnToTheLeft()), expected);
  });

  test('add row top', () {
    var expected = [
      [null, null],
      [b1, b2],
      [null, null]
    ];
    expect(order(getSimpleGrid().addRowToTheTop()), expected);
  });
  test('expand to fit and insert button', () {
    int newRow = 4;
    int newCol = 3;
    var expected = [
      [b1, b2, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, b3]
    ];
    expect(
        order(getSimpleGrid()
            .expandToFitAndSetButton(row: newRow, col: newCol, buttonData: b3)),
        expected);
  });
  test('delete row', () {
    var expected = [
      [b1, b2]
    ];
    expect(order(getSimpleGrid().removeRow(1)), expected);
  });
  test('delete col', () {
    var expected = [
      [b2],
      [null]
    ];
    expect(order(getSimpleGrid().removeCol(0)), expected);
  });
}

List<List<ButtonData?>> order(GridData data) {
  List<List<ButtonData?>> out = [];
  for (int i = 0; i < data.numberOfRows; i++) {
    out.add([]);
    for (int j = 0; j < data.numberOfColumns; j++) {
      out.last.add(data.getButtonData(i, j));
    }
  }
  return out;
}

GridData getSimpleGrid() {
  ButtonData? b3;
  ButtonData? b4;
  List<List<ButtonData?>> order = [
    [b1, b2],
    [b3, b4]
  ];
  GridData out = GridData(order: order);

  return out;
}
