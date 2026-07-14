import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:openboard_wrapper/src/has_ids.dart';

import 'button_data.dart';
import 'package:openboard_wrapper/src/obf.dart';
import 'image_data.dart';
import 'sound_data.dart';
import '_utils.dart';
import 'obz_exceptions.dart';


class  LazyObz implements HasIds {
  Obf? get root;
  set root(Obf? root);
  Map<String,dynamic> manifrestExtendedProperties;
  Map<String, dynamic> pathExtendedProperties;
  static const String defaultFromat = "open-board-0.1"
  String format;


}
