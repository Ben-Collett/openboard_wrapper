import 'dart:io';
import 'package:openboard_wrapper/openboard_wrapper.dart';

String fmtMicros(int us) {
  if (us < 1000) return '$us µs';
  if (us < 1000000)
    return '${us ~/ 1000}.${(us % 1000).toString().padLeft(3, '0')} ms';
  return '${(us / 1000000).toStringAsFixed(3)} s';
}

void main() async {
  final scriptDir = Directory(Platform.script.toFilePath()).parent;
  final dirPath = '${scriptDir.path}/quick-core-112';
  final dir = Directory(dirPath);

  final readSw = Stopwatch()..start();
  await EagarObz.fromDirectoryAsync(dir);
  readSw.stop();
  print(fmtMicros(readSw.elapsedMicroseconds));
}
