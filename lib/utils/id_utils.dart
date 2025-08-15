// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';

import 'package:PiliPlus/utils/utils.dart';
import 'package:uuid/v4.dart';

class IdUtils {
  static const XOR_CODE = 23442827791579;
  static const MASK_CODE = 2251799813685247;
  static const MAX_AID = 1 << 51;
  static const BASE = 58;

  static const data =
      'FcwAPNKTMug3GV5Lj7EJnHpWsx4tb8haYeviqBz6rkCy12mUSDQX9RdoZf';
  static final invData = {for (var (i, c) in data.codeUnits.indexed) c: i};

  static final bvRegex = RegExp(r'bv[0-9a-zA-Z]{10}', caseSensitive: false);
  static final bvRegexExact = RegExp(
    r'^bv[0-9a-zA-Z]{10}$',
    caseSensitive: false,
  );
  static final avRegex = RegExp(r'av(\d+)', caseSensitive: false);
  static final avRegexExact = RegExp(r'^av(\d+)$', caseSensitive: false);
  static final digitOnlyRegExp = RegExp(r'^\d+$');

  static void swap<T>(List<T> list, int idx1, int idx2) {
    final idx1Value = list[idx1];
    list[idx1] = list[idx2];
    list[idx2] = idx1Value;
  }

  /// av转bv
  static String av2bv(int aid) {
    final bytes = ['B', 'V', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0'];
    int bvIndex = bytes.length - 1;
    int tmp = (MAX_AID | aid) ^ XOR_CODE;
    while (tmp > 0) {
      bytes[bvIndex--] = data[tmp % BASE];
      tmp ~/= BASE;
    }

    swap(bytes, 3, 9);
    swap(bytes, 4, 7);

    return bytes.join();
  }

  /// bv转av
  static int bv2av(String bvid) {
    final bvidArr = List.of(bvid.codeUnits);

    swap(bvidArr, 3, 9);
    swap(bvidArr, 4, 7);

    bvidArr.removeRange(0, 3);
    int tmp = bvidArr.fold(0, (pre, char) => pre * BASE + invData[char]!);
    return ((tmp & MASK_CODE) ^ XOR_CODE).toInt();
  }

  // 匹配
  static Map<String, dynamic> matchAvorBv({String? input}) {
    final Map<String, dynamic> result = {};
    if (input == null || input.isEmpty) {
      return result;
    }
    String? bvid = bvRegex.firstMatch(input)?.group(0);

    late String? aid = avRegex.firstMatch(input)?.group(1);

    if (bvid != null) {
      result['BV'] = bvid;
    } else if (aid != null) {
      result['AV'] = int.parse(aid);
    }
    return result;
  }

  static String genBuvid3() {
    return '${const UuidV4().generate().toUpperCase()}${Utils.random.nextInt(100000).toString().padLeft(5, "0")}infoc';
  }

  static String genAuroraEid(int uid) {
    if (uid == 0) {
      return '';
    }

    var midByte = utf8.encode(uid.toString());

    const key = 'ad1va46a7lza';
    for (int i = 0; i < midByte.length; i++) {
      midByte[i] ^= key.codeUnitAt(i % key.length);
    }

    String base64Encoded = base64.encode(midByte).replaceAll('=', '');

    return base64Encoded;
  }

  static String genTraceId() {
    String randomId = Utils.generateRandomString(32);

    StringBuffer randomTraceId = StringBuffer(randomId.substring(0, 24));

    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (int i = 2; i >= 0; i--) {
      ts >>= 8;
      randomTraceId.write((ts & 0xFF).toRadixString(16).padLeft(2, '0'));
    }

    randomTraceId.write(randomId.substring(30, 32));

    return '${randomTraceId.toString()}:${randomTraceId.toString().substring(16, 32)}:0:0';
  }
}
