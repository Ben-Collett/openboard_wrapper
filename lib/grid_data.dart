import 'package:openboard_wrapper/button_data.dart';
import 'package:openboard_wrapper/searlizable.dart';

class GridData with Searlizable {
  List<List<ButtonData?>> _order;
  int get numberOfRows => _order.length;
  int get numberOfColumns => _order.isEmpty ? 0 : _order[0].length;
  GridData({List<List<ButtonData?>>? order}) : _order = order ?? [];

  GridData.empty({
    int rowCount = 0,
    int colCount = 0,
  }) : _order = List.generate(
          rowCount,
          (_) => List<ButtonData?>.filled(colCount, null, growable: true),
        );

  factory GridData.fromStringList({
    required List<dynamic>? orderAsStrings,
    required Map<String, ButtonData> source,
  }) {
    if (orderAsStrings == null || orderAsStrings.isEmpty) {
      return GridData();
    }
    List<List<String?>> extracted = [];
    for (dynamic list in orderAsStrings) {
      if (list is List) {
        extracted.add([]);
        for (var value in list) {
          extracted.last.add(value?.toString());
        }
      }
    }

    List<List<ButtonData?>> order = [];
    for (List<String?> list in extracted) {
      order.add([]);
      for (String? current in list) {
        if (current == null) {
          order.last.add(null);
        } else if (source.containsKey(current)) {
          order.last.add(source[current]);
        } else {
          throw ArgumentError(
              'order contains a key $current which is not null and does not exist as a key in the  source ${source.keys}');
        }
      }
    }

    return GridData(order: order);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {
      'rows': numberOfRows,
      'columns': numberOfColumns
    };
    List<List<String?>> idOrder = [];
    for (List<ButtonData?> row in _order) {
      idOrder.add(row.map((bt) => bt?.id).toList());
    }
    out['order'] = idOrder;
    return out;
  }

  void setOrder(List<List<ButtonData?>> order) {
    _order = order;
  }

  GridData addRowToTheBottom() {
    if (numberOfRows == 0) {
      _order.add([null]);
      return this;
    }
    return insertRowAt(numberOfRows);
  }

  GridData addColumnToTheRight() {
    if (numberOfRows == 0) {
      _order.add([null]);
      return this;
    }
    return insertColumnAt(numberOfColumns);
  }

  GridData addRowToTheTop() {
    if (numberOfRows == 0) {
      _order.add([null]);
      return this;
    }
    return insertRowAt(0);
  }

  GridData addColumnToTheLeft() {
    if (numberOfRows == 0) {
      _order.add([null]);
      return this;
    }
    return insertColumnAt(0);
  }

  GridData insertRowAt(int rowIndex, {List<ButtonData?>? newRow}) {
    if (rowIndex < 0 || rowIndex > _order.length) {
      throw RangeError("Row index out of range");
    }

    newRow =
        newRow ?? List<ButtonData?>.generate(_order[0].length, (index) => null);
    _order.insert(rowIndex, newRow);
    return this;
  }

  GridData insertColumnAt(int columnIndex, {List<ButtonData?>? newCol}) {
    if (columnIndex < 0 || columnIndex > _order[0].length) {
      throw RangeError("Column index out of range");
    }
    newCol = newCol ?? List<ButtonData?>.generate(_order.length, (_) => null);
    for (int i = 0; i < newCol.length; i++) {
      _order[i].insert(columnIndex, newCol[i]);
    }
    return this;
  }

  GridData removeRow(int row) {
    if (row >= 0 && row < _order.length) {
      _order.removeAt(row);
    } else {
      throw Exception("Invalid row index");
    }
    return this;
  }

  GridData removeCol(int col) {
    if (_order.isNotEmpty && col >= 0 && col < _order[0].length) {
      for (var row in _order) {
        row.removeAt(col);
      }
    } else {
      throw Exception("Invalid column index");
    }
    return this;
  }

  ButtonData? getButtonData(int row, int col) {
    return _order[row][col];
  }

  List<ButtonData?> getRow(int row) {
    if (row < 0 || row > _order.length) {
      throw Exception(
        "out of bounds, range = (0, ${_order.length}) row is $row",
      );
    }
    return _order[row];
  }

  List<ButtonData?> getCol(int col) {
    if (col < 0 || col > numberOfColumns) {
      throw Exception(
        "out of bounds, range = (0, $numberOfColumns)  col is $col",
      );
    }
    List<ButtonData?> out = [];
    for (int i = 0; i < numberOfRows; i++) {
      out.add(_order[i][col]);
    }
    return out;
  }

  Set<ButtonData> getButtons() {
    Set<ButtonData> out = _order.expand((e) => e).nonNulls.toSet();
    return out;
  }

  GridData setButtonData(
      {required int row, required int col, required ButtonData? data}) {
    _order[row][col] = data;
    return this;
  }

  GridData expandToFitAndSetButton(
      {required int row, required int col, required ButtonData? buttonData}) {
    while (numberOfRows <= row) {
      addRowToTheBottom();
    }
    while (numberOfColumns <= col) {
      addColumnToTheRight();
    }
    setButtonData(row: row, col: col, data: buttonData);
    return this;
  }

  GridData shallowCopy() {
    return GridData(order: _order);
  }
}
