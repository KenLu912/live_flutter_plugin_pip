import 'dart:async';
import 'package:flutter/services.dart';
import 'package:live_flutter_plugin/v2_tx_live_code.dart';

/// Device management
class TXDeviceManager {
  static late MethodChannel _channel;
  TXDeviceManager(channel) {
    _channel = channel;
  }

  /// Set whether to use the front camera (supports only the Android and iOS platforms)
  Future<bool?> isFrontCamera() async {
    var result = await _channel.invokeMethod('isFrontCamera');
    return V2TXLiveFlutterResult.boolValue(result);
  }

  /// Switch camera (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `isFrontCamera`: `true`: front camera; `false`: rear camera
  Future<int?> switchCamera(bool isFrontCamera) async {
    var result = await _channel
        .invokeMethod('switchCamera', {"isFrontCamera": isFrontCamera});
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Get the camera zoom factor (supports only the Android and iOS platforms)
  Future<double?> getCameraZoomMaxRatio() async {
    var result = await _channel.invokeMethod('getCameraZoomMaxRatio');
    return V2TXLiveFlutterResult.doubleValue(result);
  }

  /// Set the zoom factor (focal length) of camera (supports only the Android and iOS platforms)
  ///
  /// The value range is `1`–`5`. `1` indicates the furthest view (normal lens), and `5` indicates the nearest view (enlarging lens). We recommend you set the maximum value to `5`. If the maximum value is greater than `5`, the video will become blurry.
  ///
  /// **Parameters:**
  ///
  /// `value` Value range: `1`–`5`. The greater the value, the further the focal length
  ///
  /// **Return:** `0`: success; negative number: failure
  Future<int?> setCameraZoomRatio(double value) async {
    var result = await _channel.invokeMethod('setCameraZoomRatio', {
      "value": value.toString(),
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set whether to enable the automatic recognition of face position (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `enable`   `true`: enabled; `false`: disabled. Default value: `true`
  ///
  /// **Return:** `0`: success; negative number: failure
  Future<int?> enableCameraAutoFocus(bool enable) async {
    var result = await _channel.invokeMethod('enableCameraAutoFocus', {
      "enable": enable,
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Query whether the device supports automatic recognition of face position (supports only the Android and iOS platforms)
  ///
  /// **Return:** `true`: supported; `false`: not supported
  Future<bool?> isAutoFocusEnabled() async {
    var result = await _channel.invokeMethod('isAutoFocusEnabled');
    return V2TXLiveFlutterResult.boolValue(result);
  }

  /// Set camera focus (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `x` X coordinate of focus position
  ///
  /// `y` Y coordinate of focus position
  Future<void> setCameraFocusPosition(int x, int y) {
    return _channel.invokeMethod('setCameraFocusPosition', {
      "x": x,
      "y": y,
    });
  }

  /// Enable/Disable flash (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `enable` `true`: enabled; `false`: disabled. Default value: `false`
  Future<int?> enableCameraTorch(bool enable) async {
    var result = await _channel.invokeMethod('enableCameraTorch', {
      "enable": enable,
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set the system volume type used in call (supports only the Android and iOS platforms)
  ///
  /// Smartphones usually have two system volume types, i.e., call volume and media volume.
  ///
  /// Currently, the SDK provides three control modes of system volume types, including:
  ///
  ///* [TXSystemVolumeType.TXSystemVolumeTypeAuto] "Call on the microphone, media under the microphone", that is, the call volume is used when the anchor is on the microphone, and the media volume is used when the audience is not on the microphone, which is suitable for online live broadcast scenarios.
  ///
  ///* [TXSystemVolumeType.TXSystemVolumeTypeVOIP] The call volume is used throughout the call, which is suitable for multi-person conference scenarios.
  ///
  ///* [TXSystemVolumeType.TXSystemVolumeTypeMedia] The media volume is used throughout the call, which is not commonly used, and is suitable for some application scenarios with special needs (such as the anchor's external sound card).
  ///
  /// **Note:**
  ///
  ///* If you have no special requirements, it is not recommended that you set it yourself, and the SDK will automatically select the corresponding volume type.
  ///
  /// **Parameters:**
  ///
  /// `type`	If there are no special requirements, it is not recommended that you set the system volume type by yourself. Reference: [TXSystemVolumeType]
  /// - 0: Automatic mode switching  [TXSystemVolumeType.TXSystemVolumeTypeAuto]
  /// - 1: Full media volume [TXSystemVolumeType.TXSystemVolumeTypeMedia]
  /// - 2: The volume of the whole call [TXSystemVolumeType.TXSystemVolumeTypeVOIP]
  Future<int?> setSystemVolumeType(int type) async {
    var result = await _channel.invokeMethod('setSystemVolumeType', {
      "type": type,
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set audio route, i.e., earpiece at the top or speaker at the bottom (supports only the Android and iOS platforms)
  ///
  /// The hands-free mode of video call features in WeChat and Mobile QQ is implemented based on audio routing. Generally, a mobile phone has two speakers: one is the receiver at the top with low volume, and the other is the stereo speaker at the bottom with high volume. The purpose of setting audio routing is to determine which speaker will be used.
  ///
  /// **Parameters:**
  ///
  /// `route`	Audio route, i.e., whether the audio is output by speaker or receiver. Reference: [TXAudioRoute]
  Future<int?> setAudioRoute(int route) async {
    var result = await _channel.invokeMethod('setAudioRoute', {
      "route": route,
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Get the list of devices (Support for macOS, Windows and web platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic]、[TRTCCloudDef.TXMediaDeviceTypeSpeaker], or [TRTCCloudDef.TXMediaDeviceTypeCamera].
  Future<Map?> getDevicesList(int type
      ) async {
    var result = await _channel.invokeMapMethod('getDevicesList', {
      "type": type,
    });
    return V2TXLiveFlutterResult.mapValue(result);
  }

  /// Specify the current device (Support for macOS, Windows and web platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic]、[TRTCCloudDef.TXMediaDeviceTypeSpeaker], or [TRTCCloudDef.TXMediaDeviceTypeCamera].
  ///
  /// `deviceId` Device ID obtained from [getDevicesList]
  ///
  /// **Return:**
  ///
  /// `0`: success; negative number: failure
  Future<int?> setCurrentDevice(int type, String deviceId
      ) async {
    var result = await _channel.invokeMethod('setCurrentDevice', {
      "type": type,
      "deviceId": deviceId
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Get the currently used device (Support for macOS, Windows and web platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic]、[TRTCCloudDef.TXMediaDeviceTypeSpeaker], or [TRTCCloudDef.TXMediaDeviceTypeCamera].
  ///
  /// `deviceId` Device ID obtained from `getDevicesList`
  ///
  /// **Return:**
  ///
  /// `ITRTCDeviceInfo` device information, from which the device ID and device name can be obtained
  Future<Map?> getCurrentDevice(int type
      ) async {
    var result = await _channel.invokeMapMethod('getCurrentDevice', {
      "type": type
    });
    return V2TXLiveFlutterResult.mapValue(result);
  }

  /// Set the volume of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// `volume` Volume
  ///
  /// **Return:**
  ///
  /// `ITRTCDeviceInfo` device information, from which the device ID and device name can be obtained
  Future<int?> setCurrentDeviceVolume(int type, int volume) async {
    var result = await _channel.invokeMethod('setCurrentDeviceVolume', {
      "type": type,
      "volume": volume
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Get the volume of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// **Return:**
  ///
  /// Volume
  Future<int?> getCurrentDeviceVolume(int type
      ) async {
    var result = await _channel.invokeMethod('getCurrentDeviceVolume', {
      "type": type
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set the mute status of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// `mute` Whether to mute/freeze
  ///
  /// **Return:**
  ///
  /// `0`: success; negative number: failure
  Future<int?> setCurrentDeviceMute(int type, bool mute
      ) async {
    var result = await _channel.invokeMethod('setCurrentDeviceMute', {
      "type": type,
      "mute": mute
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Query the mute status of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// **Return:**
  ///
  /// `true`: the current device is muted; `false`: the current device is not muted
  Future<bool?> getCurrentDeviceMute(int type
      ) async {
    var result = _channel.invokeMethod('getCurrentDeviceMute', {
      "type": type
    });
    return V2TXLiveFlutterResult.boolValue(result);
  }

  /// Start mic test (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `interval` Volume callback interval in ms
  ///
  /// **Return:**
  ///
  /// `0`: success; negative number: failure
  Future<int?> startMicDeviceTest(int interval
      ) async {
    var result = await _channel.invokeMethod('startMicDeviceTest', {
      "interval": interval
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Stop mic test (Support for macOS and Windows platforms)
  ///
  /// **Return:**
  ///
  /// `0`: success; negative number: failure
  Future<int?> stopMicDeviceTest() async {
    var result = await _channel.invokeMethod('stopMicDeviceTest');
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Start speaker test (Support for macOS and Windows platforms)
  ///
  /// This method plays back the specified audio data to test whether the speaker can function properly. If sound can be heard, the speaker is normal.
  ///
  /// **Parameters:**
  ///
  /// `filePath` Audio file path
  ///
  /// **Return:**
  ///
  /// `0`: success; negative number: failure
  Future<int?> startSpeakerDeviceTest(String filePath
      ) async {
    var result = await _channel.invokeMethod('startSpeakerDeviceTest', {
      "filePath": filePath
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Stop speaker test (Support for macOS and Windows platforms)
  ///
  /// **Return:**
  ///
  /// `0`: success; negative number: failure
  Future<int?> stopSpeakerDeviceTest() async {
    var result = await _channel.invokeMethod('stopSpeakerDeviceTest');
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set the volume of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. Value range: `[0,100]`
  ///
  /// **Return:**
  ///
  /// `0`: success
  Future<int?> setApplicationPlayVolume(int volume
      ) async {
    var result = _channel.invokeMethod('setApplicationPlayVolume', {
      "volume": volume
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Get the volume of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Return:**
  ///
  /// Returned volume value. Value range: `[0,100]`
  Future<int?> getApplicationPlayVolume() async {
    var result = await _channel.invokeMethod('getApplicationPlayVolume');
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Set the mute status of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Parameters:**
  ///
  /// `bMute` Whether to mute
  ///
  /// **Return:**
  ///
  /// `0`: success
  Future<int?> setApplicationMuteState(bool	bMute
      ) async {
    var result = await _channel.invokeMethod('setApplicationMuteState', {
      "bMute": bMute
    });
    return V2TXLiveFlutterResult.intValue(result);
  }

  /// Get the mute status of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Return:**
  ///
  /// Returned mute status
  Future<bool?> getApplicationMuteState() async {
    var result = await _channel.invokeMethod('getApplicationMuteState');
    return V2TXLiveFlutterResult.boolValue(result);
  }
}
