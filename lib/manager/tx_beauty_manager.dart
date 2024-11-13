import 'dart:async';
import 'package:flutter/services.dart';
import 'package:live_flutter_plugin/v2_tx_live_code.dart';

enum TXBeautyStyle {
  /// Smooth, the algorithm is more aggressive, and the dermabrasion effect is more obvious, which is suitable for live shows.
  tXBeautyStyleSmooth,

  /// Naturally, the algorithm retains more facial details, and the dermabrasion effect is more natural, which is suitable for the vast majority of live broadcast scenarios.
  tXBeautyStyleNature,

  /// Youtu, provided by Youtu Labs, has a dermabrasion effect between smooth and natural, which retains more skin details than smooth and has a higher degree of dermabrasion than natural dermabrasion.
  tXBeautyStylePitu,
}

/// Beauty filter and animation parameter management
class TXBeautyManager {
  static late MethodChannel _channel;
  TXBeautyManager(channel) {
    _channel = channel;
  }

  /// Set beauty filter type
  ///
  /// **Parameters:**
  ///
  /// `beautyStyle`	Beauty filter style.
  /// - [TXBeautyStyle.tXBeautyStyleSmooth] ：Smooth
  /// - [TXBeautyStyle.tXBeautyStyleNature]：Naturally
  /// - [TXBeautyStyle.tXBeautyStylePitu]：Youtu
  Future<void> setBeautyStyle(TXBeautyStyle beautyStyle) {
    return _channel
        .invokeMethod('setBeautyStyle', {"beautyStyle": beautyStyle.index});
  }

  /// Set the strength of the beauty filter
  ///
  /// **Parameters:**
  ///
  /// `beautyLevel` Strength of the beauty filter. Value range: `0`–`9`; `0` indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  Future<void> setBeautyLevel(int beautyLevel) {
    return _channel
        .invokeMethod('setBeautyLevel', {"beautyLevel": beautyLevel.toString()});
  }

  /// Set the strength of the brightening filter
  ///
  /// **Parameters:**
  ///
  /// whitenessLevel Strength of the brightening filter. Value range: `0`–`9`; `0` indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  Future<void> setWhitenessLevel(int whitenessLevel) {
    return _channel
        .invokeMethod('setWhitenessLevel', {"whitenessLevel": whitenessLevel.toString()});
  }

  /// Enable definition enhancement
  ///
  /// **Parameters:**
  ///
  /// `enable` `true`: enables definition enhancement; `false`: disables definition enhancement. Default value: `true`
  Future<void> enableSharpnessEnhancement(bool enable) {
    return _channel
        .invokeMethod('enableSharpnessEnhancement', {"enable": enable});
  }

  /// Set the strength of the rosy skin filter
  ///
  /// **Parameters:**
  ///
  /// `ruddyLevel` Strength of the rosy skin filter. Value range: `0`–`9`; `0` indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  Future<void> setRuddyLevel(int ruddyLevel) {
    return _channel.invokeMethod('setRuddyLevel', {"ruddyLevel": ruddyLevel.toString()});
  }

  /// Specify material filter effect
  ///
  /// **Parameters:**
  ///
  /// `assetUrl` can be an asset resource address defined in Flutter such as 'images/watermark_img.png' or an online image address
  ///
  /// **Note:** PNG format must be used
  Future<int?> setFilter(String assetUrl) async {
    String imageUrl = assetUrl;
    String type = 'network'; //The default is a network image
    if (assetUrl.indexOf('http') != 0) {
      type = 'local';
    }
    var result =  _channel
        .invokeMethod('setFilter', {"imageUrl": imageUrl, "type": type});
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set the strength of filter
  ///
  /// In application scenarios such as shows, a high strength is required to highlight the characteristics of anchors. The default strength is `0.5`, and if it is not sufficient, it can be adjusted with the following APIs.
  ///
  /// **Parameters:**
  ///
  /// `strength` Value range: `0`–`1`. The greater the value, the more obvious the effect. Default value: `0.5`.
  Future<void> setFilterStrength(double strength) {
    return _channel
        .invokeMethod('setFilterStrength', {"strength": strength.toString()});
  }
}
