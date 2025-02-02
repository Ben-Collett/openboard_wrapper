import 'package:openboard_searlizer/obf.dart';
import 'package:openboard_searlizer/image_data.dart';
import 'package:openboard_searlizer/sound_data.dart';
import 'package:openboard_searlizer/_utils.dart';

class Obz {
  List<Obf> boards = [];
  List<ImageData> _images = [];
  List<ImageData> get images {
    List<ImageData> images = [];
    images.addAll(images);
    for (var board in boards) {
      images.addAll(board.images);
    }

    return []; //TODO
  }

  List<SoundData> get sounds {
    return []; //TODO
  }

  List<Map<String, dynamic>> get boardJsons {
    return [];
  }

  Map<String, dynamic> get manifestJson {
    return {};
  }

  Obz autoResolveAllIdCollisionsInFile({String Function(String)? onCollision}) {
    List<HasId> toResolve = [];
    toResolve.addAll(boards);
    toResolve.addAll(images);
    toResolve.addAll(sounds);
    autoResolveIdCollisions(toResolve, onCollision: onCollision);
    return this;
  }
}
