import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_flutter_plugin/v2_tx_live_def.dart';

void main() {

  V2TXLiveVideoEncoderParam param = V2TXLiveVideoEncoderParam();
  if (kDebugMode) {
    print("param:${jsonEncode(param)}");
  }

}
