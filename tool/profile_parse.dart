import 'dart:io';
import 'package:openboard_wrapper/openboard_wrapper.dart';

String fmtMicros(int us) {
  if (us < 1000) return '$us µs';
  if (us < 1000000) return '${us ~/ 1000}.${(us % 1000).toString().padLeft(3, '0')} ms';
  return '${(us / 1000000).toStringAsFixed(3)} s';
}

void main() {
  final scriptDir = Directory(Platform.script.toFilePath()).parent;
  final dirPath = '${scriptDir.path}/quick-core-112';
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: $dirPath');
    exit(1);
  }

  // ---- Phase 1: list all files ----
  final listSw = Stopwatch()..start();
  final allEntries = dir.listSync(recursive: true);
  final obfFiles = allEntries
      .whereType<File>()
      .where((f) => f.path.endsWith('.obf'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  File? manifestFile;
  for (final entry in allEntries) {
    if (entry is File && entry.path.endsWith('manifest.json')) {
      manifestFile = entry;
      break;
    }
  }
  listSw.stop();
  final listUs = listSw.elapsedMicroseconds;

  // ---- Phase 2: read + parse manifest.json ----
  int manifestReadUs = 0;
  int manifestParseUs = 0;
  int manifestKeys = 0;
  if (manifestFile != null) {
    final readSw = Stopwatch()..start();
    final manifestString = manifestFile.readAsStringSync();
    readSw.stop();
    manifestReadUs = readSw.elapsedMicroseconds;

    final obz = EagarObz();
    final parseSw = Stopwatch()..start();
    obz.parseManifestString(manifestString);
    parseSw.stop();
    manifestParseUs = parseSw.elapsedMicroseconds;
    manifestKeys = obz.manifestExtendedProperties.length;
  }

  // ---- Phase 3: parse each board ----
  int totalBoardUs = 0;
  int totalBoardButtons = 0;
  final boardTimes = <({String name, int us, int buttons})>[];

  for (final file in obfFiles) {
    final sw = Stopwatch()..start();
    final board = Obf.fromFile(file);
    sw.stop();
    final us = sw.elapsedMicroseconds;
    totalBoardUs += us;
    totalBoardButtons += board.buttons.length;
    boardTimes.add((
      name: file.path.split('/').last,
      us: us,
      buttons: board.buttons.length,
    ));
  }

  // ---- Phase 4: full EagarObz.fromDirectory for comparison ----
  final fullSw = Stopwatch()..start();
  final obz = EagarObz.fromDirectory(dir);
  fullSw.stop();
  final fullUs = fullSw.elapsedMicroseconds;

  // ---- Report ----
  print('=== Phased timing (µs precision) ===\n');

  print('  Phase 1 — List files:          ${fmtMicros(listUs)}');
  print('    Entries scanned:    ${allEntries.length}');
  print('    .obf files found:   ${obfFiles.length}');
  print('    manifest.json found: ${manifestFile != null}');

  print('');
  print('  Phase 2 — Manifest.json:');
  print('    Read:               ${fmtMicros(manifestReadUs)}');
  print('    Parse manifest:     ${fmtMicros(manifestParseUs)}');
  if (manifestFile != null) {
    print('    ext properties:     $manifestKeys');
  }

  print('');
  print('  Phase 3 — Board parsing (${obfFiles.length} boards):');
  print('    Total:              ${fmtMicros(totalBoardUs)}');
  print('    Average:            ${fmtMicros(totalBoardUs ~/ obfFiles.length)}');
  print('    Total buttons:      $totalBoardButtons');

  boardTimes.sort((a, b) => b.us.compareTo(a.us));
  final topN = boardTimes.length > 5 ? 5 : boardTimes.length;
  print('');
  print('    Top $topN slowest boards:');
  for (final bt in boardTimes.take(topN)) {
    print(
      '      ${bt.name.padRight(30)} ${fmtMicros(bt.us).padLeft(14)}  (${bt.buttons} buttons)',
    );
  }
  final fastest = boardTimes.last;
  print(
    '      ${fastest.name.padRight(30)} ${fmtMicros(fastest.us).padLeft(14)}  (${fastest.buttons} buttons)  ← fastest',
  );

  print('');
  print('  Phase 4 — EagarObz.fromDirectory total:');
  print('    Full constructor:   ${fmtMicros(fullUs)}');
  final accounted = listUs + manifestReadUs + manifestParseUs + totalBoardUs;
  print('    Sum of phases 1-3:  ${fmtMicros(accounted)}');
  print(
    '    Unaccounted:        ${fmtMicros(fullUs - accounted)}',
  );

  print('');
  print('=== Final object counts ===');
  print('  Boards: ${obz.boards.length}');
  print('  Images: ${obz.images.length}');
  print('  Sounds: ${obz.sounds.length}');
}
