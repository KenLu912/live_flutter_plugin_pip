import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'manager/tx_live_manager.dart';
import 'v2_tx_live_code.dart';
import 'v2_tx_live_def.dart';
import 'v2_tx_live_player_observer.dart';

/// Live stream player
class V2TXLivePlayer {
  int status = 0;
  late MethodChannel _channel;
  late String _identifier;
  late Set<V2TXLivePlayerObserver> _listeners;

  V2TXLivePlayer() {
    _identifier = const Uuid().v1();
    _listeners = {};
    _initMethodChannel(_identifier);
    _createNativePlayer(_identifier);
  }

  V2TXLivePlayer._create() {
    _identifier = const Uuid().v1();
    _listeners = {};
    _initMethodChannel(_identifier);
  }

  /// Create an instance
  static Future<V2TXLivePlayer> create() async {
    var player = V2TXLivePlayer._create();
    await player._createNativePlayer(player._identifier);
    return player;
  }

  /// MethodChannel init
  _initMethodChannel(String identifier) {
    // init Method Channel
    _channel = MethodChannel("player_$identifier");
    // methodChannel CallHandler
    _channel.setMethodCallHandler((MethodCall call) async {
      debugPrint("MethodCallHandler method: ${call.method}");
      var arguments = call.arguments;
      if (arguments is Map) {
        debugPrint("arguments is Map: $arguments");
      } else {
        debugPrint("arguments isn't Map: $arguments");
      }
      if (call.method == "onPlayerListener") {
        String typeStr = arguments['type'];
        var params = arguments['params'];
        debugPrint("on Player Listener: type:$typeStr");

        V2TXLivePlayerListenerType? callType;
        for (var subType in V2TXLivePlayerListenerType.values) {
          if (subType.toString().replaceFirst("V2TXLivePlayerListenerType.", "") == typeStr) {
            callType = subType;
            break;
          }
        }
        if (callType != null) {
          _doListenerCallBack(callType, params);
        }
      } else {
        debugPrint("on Player Listener: MethodNotImplemented ${call.method}");
      }
    });
  }

  /// Player callback
  void _doListenerCallBack(V2TXLivePlayerListenerType type, params) {
    for (var item in _listeners) {
      item(type, params);
    }
  }

  /// Add a player callback
  ///
  /// By setting callbacks, you can listen to some callback events of the V2TXLivePlayer player,
  /// This includes player status, playback volume callback, first frame callback of audio and video, statistical data, warnings, and error messages.
  ///
  /// **Parameter:**
  ///
  /// `observer` the target object of the player's callback, For more information, please see [V2TXLivePlayerObserver]
  void addListener(V2TXLivePlayerObserver observer) {
    _listeners.add(observer);
  }

  /// remove a player callback
  ///
  /// **Parameter:**
  ///
  /// `observer` the target object of the player's callback, For more information, please see [V2TXLivePlayerObserver]
  void removeListener(V2TXLivePlayerObserver observer) {
    _listeners.remove(observer);
  }

  /// Destroy the instance
  void destroy() {
    _listeners.clear();
    TXLiveManager.destroyPlayer(_identifier);
  }

  Future<void> _createNativePlayer(String identifier) async {
    int result;
    try {
      result = await TXLiveManager.createPlayer(identifier);
    } on PlatformException {
      result = -1;
    }
    // debugPrint("create pusher result $result identifier $identifier");
    status = result;
  }

  /// V2TXLiveCode Error code return value processing
  V2TXLiveCode _liveCodeWithResult<T>(T? result) {
    return V2TXLiveFlutterResult.v2TXLiveCode(result) ?? V2TXLIVE_ERROR_FAILED;
  }

  /// Set the ID of the rendered view
  ///
  /// **Parameter:**
  ///
  /// `viewID` The ID of the local rendered view
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderViewID(int viewID) async {
    var result = await _channel.invokeMethod("setRenderView", {"id": viewID});
    return _liveCodeWithResult(result);
  }

  /// Sets the rotation angle of the local rendered picture
  ///
  /// **Parameter:**
  ///
  /// `rotation` Rotation angle [V2TXLiveRotation]
  /// - [V2TXLiveRotation.v2TXLiveRotation0] Default value: 0 degrees, no rotation
  /// - [V2TXLiveRotation.v2TXLiveRotation90]  Rotate 90 degrees clockwise
  /// - [V2TXLiveRotation.v2TXLiveRotation180] Rotate 180 degrees clockwise
  /// - [V2TXLiveRotation.v2TXLiveRotation270] Rotate 270 degrees clockwise
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderRotation(V2TXLiveRotation rotation) async {
    var result = await _channel.invokeMethod(
        'setRenderRotation', {"rotation": rotation.index});
    return _liveCodeWithResult(result);
  }

  /// Set the fill mode of the picture
  ///
  /// **Parameter:**
  /// `mode` Picture fill mode [V2TXLiveFillMode]
  /// - [V2TXLiveFillMode.v2TXLiveFillModeFill] Default: The image covers the screen without black bars, and if the aspect ratio of the image is different from the aspect ratio of the screen, part of the image content will be cropped
  /// - [V2TXLiveFillMode.v2TXLiveFillModeFit] The image adapts to the screen and keeps the picture intact, but if the image aspect ratio is different from the screen aspect ratio, there will be black bars
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderFillMode(V2TXLiveFillMode mode) async {
    var result = await _channel.invokeMethod('setRenderFillMode', {"mode": mode.index});
    return _liveCodeWithResult(result);
  }

  /// Start playing the audio and video stream
  ///
  /// **Parameter:**
  ///
  /// `url` The playback URL of the audio and video stream, which supports RTMP, HTTP-FLV, and TRTC.
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startLivePlay(String url) async {
    var result = await _channel.invokeMethod('startLivePlay', {"url": url});
    return _liveCodeWithResult(result);
  }

  /// Stop playing the audio and video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopPlay() async {
    var result = await _channel.invokeMethod('stopPlay', {});
    return _liveCodeWithResult(result);
  }

  /// Whether the player is playing or not
  ///
  /// **Return:**
  /// - 1: Now playing
  /// - 0: Playback has stopped
  Future<V2TXLiveCode> isPlaying() async {
    var result = await _channel.invokeMethod('isPlaying', {});
    return _liveCodeWithResult(result);
  }

  /// Pause the player's audio stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> pauseAudio() async {
    var result = await _channel.invokeMethod('pauseAudio', {});
    return _liveCodeWithResult(result);
  }

  /// Resume the player's audio stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> resumeAudio() async {
    var result = await _channel.invokeMethod('resumeAudio', {});
    return _liveCodeWithResult(result);
  }

  /// Pause the player's video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> pauseVideo() async {
    var result = await _channel.invokeMethod('pauseVideo', {});
    return _liveCodeWithResult(result);
  }

  /// Restore the player's video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> resumeVideo() async {
    var result = await _channel.invokeMethod('resumeVideo', {});
    return _liveCodeWithResult(result);
  }

  /// Set the player volume
  ///
  /// **Parameter:**
  ///
  /// `volume` The volume ranges from 0 to 100. Default value: 100
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setPlayoutVolume(int volume) async {
    var result = await _channel.invokeMethod('setPlayoutVolume', {"volume": volume});
    return _liveCodeWithResult(result);
  }

  /// Set the minimum and maximum time (in seconds) for the player cache to automatically adjust
  ///
  /// **Parameter:**
  ///
  /// `minTime` The minimum time for the cache to be automatically adjusted must be greater than 0. Default value: 1
  ///
  /// `maxTime` The maximum time for cache auto-adjustment must be greater than 0. Default value: 5
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: The operation failed, and minTime and maxTime need to be greater than 0
  /// - V2TXLIVE_ERROR_REFUSED: The player is in the playback state and cannot modify the cache policy
  Future<V2TXLiveCode> setCacheParams(double minTime, double maxTime) async {
    var result = await _channel.invokeMethod('setCacheParams', {
      "minTime": minTime.toString(),
      "maxTime": maxTime.toString()
    });
    return _liveCodeWithResult(result);
  }

  /// Enable playback volume level prompts
  ///
  /// After this is enabled, you can get the SDK's evaluation of the volume value in the [V2TXLivePlayerListenerType.onPlayoutVolumeUpdate] callback.
  ///
  /// **Parameter:**
  ///
  /// `intervalMs` determines the trigger interval of the [V2TXLivePlayerListenerType.onPlayoutVolumeUpdate] callback, the unit is ms, the minimum interval is 100ms, if it is less than or equal to 0, the callback will be disabled, it is recommended to set it to 300ms; Default value: 0, not enabled
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableVolumeEvaluation(int intervalMs) async {
    var result = await _channel.invokeMethod(
        'enableVolumeEvaluation', {"intervalMs": intervalMs});
    return _liveCodeWithResult(result);
  }

  /// Capture the video during playback
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: The player is in a stopped state and is not allowed to invoke the screenshot operation
  Future<V2TXLiveCode> snapshot() async {
    var result = await _channel.invokeMethod('snapshot', {});
    return _liveCodeWithResult(result);
  }

  ///  Enable/disable the listening callback for video frames
  ///
  /// After you enable this toggle again, the SDK will no longer render the video footage, you can use [V2TXLivePlayerObserver] to obtain the video frame and execute the custom rendering logic.
  ///
  /// **Parameter:**
  ///
  /// `enable`      Whether to enable custom rendering. Default: false
  ///
  /// `pixelFormat` Customize the video pixel format of the render callback [V2TXLivePixelFormat]
  ///
  /// `bufferType`  Customize the video data format of the render callback [V2TXLiveBufferType]
  ///
  /// **Return:**
  ///
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_NOT_SUPPORTED: Pixel formats or data formats are not supported
  Future<V2TXLiveCode> enableObserveVideoFrame(
      bool enable, int pixelFormat, int bufferType) async {
    var result = await _channel.invokeMethod('enableObserveVideoFrame', {
      "enable": enable,
      "pixelFormat": pixelFormat,
      "bufferType": bufferType
    });
    return _liveCodeWithResult(result);
  }

  /// Turn on receiving SEI messages
  ///
  /// **Parameter:**
  ///
  /// `enable`       true: Enable receiving SEI messages; false: Disables receiving SEI messages. Default: false
  ///
  /// 'payloadType' specifies the payloadType to receive SEI messages, 5 and 242 are supported, please be consistent with the payloadType of the sender.
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableReceiveSeiMessage(
      bool enable, int payloadType) async {
    var result = await _channel.invokeMethod('enableReceiveSeiMessage',
        {"enable": enable, "payloadType": payloadType});
    return _liveCodeWithResult(result);
  }

  /// Display the dashboard
  ///
  /// **Parameter:**
  ///
  /// `isShow` Whether it is displayed or not. Default: false
  Future<void> showDebugView(bool isShow) async {
    await _channel.invokeMethod('showDebugView', {"isShow": isShow});
  }

  /// Call the high-level API interface of V2TXLivePlayer
  ///
  /// **Parameter:**
  ///
  /// `key`   The key corresponding to the high-level API
  ///
  /// `value` When calling the high-level API corresponding to the key, the parameter required is a base type or jsonString
  ///
  /// **Return:**
  ///
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: If the operation fails, the key is not allowed to be null
  Future<V2TXLiveCode> setProperty(String key, Object value) async {
    var result = await _channel.invokeMethod(
        'setProperty', {"key": key, "value": value});
    return _liveCodeWithResult(result);
  }

  /// Whether to turn on picture-in-picture mode
  ///
  /// **Parameter:**
  ///
  /// `enable`  Whether to enable picture-in-picture mode. Default: false
  ///
  /// **Return:**
  ///
  /// - V2TXLIVE_OK: Succeed
  Future<V2TXLiveCode> enablePictureInPicture(bool enable) async {
    var result = await _channel.invokeMethod('enablePictureInPicture', {"enable": enable});
    return _liveCodeWithResult(result);
  }
}
