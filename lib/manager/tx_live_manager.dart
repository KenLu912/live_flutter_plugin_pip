///
///    Created by aby$ on 12/22/21$.
///

import 'dart:async';
import 'package:flutter/services.dart';
import '../v2_tx_live_def.dart';

 class TXLiveManager {
  static const MethodChannel _channel = MethodChannel('live_cloud_manager_channel');

  static Future<int> createPusher(String identifier, V2TXLiveMode mode) async {
    final int? result = await _channel.invokeMethod('createNativePusher',{
      'identifier' : identifier,
      'mode' : mode.index
    });
    return result ?? -1;
  }

  static Future<int> destroyPusher(String identifier) async {
    final int? result = await _channel.invokeMethod('destroyNativePusher',{
      'identifier' : identifier
    });
    return result ?? -1;
  }

  static Future<int> createPlayer(String identifier) async {
    final int? result = await _channel.invokeMethod('createNativePlayer',{
      'identifier' : identifier
    });
    return result ?? -1;
  }

  static Future<int> destroyPlayer(String identifier) async {
    final int? result = await _channel.invokeMethod('destroyNativePlayer',{
      'identifier': identifier
    });
    return result ?? -1;
  }

}