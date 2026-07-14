import 'obf.dart';

class NoRootBoardException implements Exception {
  @override
  String toString() {
    return "The manifest must have a root board";
  }
}

class NoRootPathException implements Exception {
  final Obf root;
  final Map<Obf, String> boardPaths;
  NoRootPathException({required this.root, required this.boardPaths});
  @override
  String toString() {
    return "The root board must have a path defined in boardPaths, root id = ${root.id}, boardPaths = $boardPaths";
  }
}
