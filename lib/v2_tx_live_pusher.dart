import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:live_flutter_plugin/manager/tx_audio_effect_manager.dart';
import 'package:live_flutter_plugin/manager/tx_beauty_manager.dart';
import 'package:live_flutter_plugin/manager/tx_device_manager.dart';

import 'package:uuid/uuid.dart';

import 'v2_tx_live_code.dart';
import 'v2_tx_live_def.dart';
import 'manager/tx_live_manager.dart';
import 'v2_tx_live_pusher_observer.dart';

/// Live stream pusher
class V2TXLivePusher {
  int status = 0;

  late MethodChannel _channel;
  late String _identifier;
  late Set<V2TXLivePusherObserver> _listeners;

  late TXAudioEffectManager _audioEffectManager;
  late TXBeautyManager _beautyManager;
  late TXDeviceManager _deviceManager;

  V2TXLivePusher(V2TXLiveMode liveMode) {
    _identifier = const Uuid().v1();
    _listeners = {};
    _initMethodChannel(_identifier);
    _audioEffectManager = TXAudioEffectManager(_channel);
    _beautyManager = TXBeautyManager(_channel);
    _deviceManager = TXDeviceManager(_channel);
    _createNativePusher(_identifier, liveMode);
  }

  V2TXLivePusher._create(V2TXLiveMode liveMode) {
    _identifier = const Uuid().v1();
    _listeners = {};
    _initMethodChannel(_identifier);
    _audioEffectManager = TXAudioEffectManager(_channel);
    _beautyManager = TXBeautyManager(_channel);
    _deviceManager = TXDeviceManager(_channel);
  }

  /// Create an instance
  static Future<V2TXLivePusher> create(V2TXLiveMode liveMode) async {
    var pusher = V2TXLivePusher._create(liveMode);
    await pusher._createNativePusher(pusher._identifier, liveMode);
    return pusher;
  }

  /// MethodChannel init
  _initMethodChannel(String identifier) {
    // init Method Channel
    _channel = MethodChannel("pusher_$_identifier");
    // methodChannel CallHandler
    _channel.setMethodCallHandler((MethodCall call) async {
      debugPrint("MethodCallHandler method: ${call.method}");
      var arguments = call.arguments;
      if (arguments is Map) {
        debugPrint("arguments is Map: $arguments");
      } else {
        debugPrint("arguments isn't Map: $arguments");
      }
      if (call.method == "onPusherListener") {
        var typeStr = arguments['type'];
        var params = arguments['params'];
        debugPrint("on Pusher Listener: type: $typeStr");

        V2TXLivePusherListenerType? callType;
        for (var subType in V2TXLivePusherListenerType.values) {
          if (subType.toString().replaceFirst("V2TXLivePusherListenerType.", "") == typeStr) {
            callType = subType;
            break;
          }
        }
        if (callType != null) {
          _doListenerCallBack(callType, params);
        }
      } else {
        debugPrint("on Pusher Listener: MethodNotImplemented ${call.method}");
      }
    });
  }

  /// Pusher callback
  void _doListenerCallBack(V2TXLivePusherListenerType type, params) {
    for (var item in _listeners) {
      item(type, params);
    }
  }

  /// Add a pusher callback
  ///
  /// By setting callbacks, you can listen to some callback events of the V2TXLivePusher streamer,
  /// including the streamer status, volume callback, statistics, warnings, and error messages.
  ///
  /// **Parameter:**
  ///
  /// `observer` the target object of the pusher's callback, For more information, please see [V2TXLivePusherObserver]
  void addListener(V2TXLivePusherObserver observer) {
    _listeners.add(observer);
  }

  /// Remove a pusher callback
  ///
  /// **Parameter:**
  ///
  /// `observer` the target object of the pusher's callback, For more information, please see [V2TXLivePusherObserver]
  void removeListener(V2TXLivePusherObserver observer) {
    _listeners.remove(observer);
  }

  /// Destroy the instance
  void destroy() {
    _listeners.clear();
    TXLiveManager.destroyPusher(_identifier);
  }

  Future<void> _createNativePusher(String identifier, V2TXLiveMode mode) async {
    int result;
    try {
      result = await TXLiveManager.createPusher(identifier, mode);
    } on PlatformException {
      result = -1;
    }
    debugPrint("create pusher result $result identifier $identifier");
    status = result;
  }

  /// V2TXLiveCode Error code return value processing
  V2TXLiveCode _liveCodeWithResult(result) {
    return V2TXLiveFlutterResult.v2TXLiveCode(result) ?? V2TXLIVE_ERROR_FAILED;
  }

  /// Set the ID of the local camera preview
  ///
  /// The image captured by the local camera will be displayed on the incoming View after being superimposed with various effects such as beautification, face shape adjustment, and filters.
  ///
  /// **Parameter:**
  ///
  /// `identifier` Local camera preview ID
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderViewID(int viewID) async {
    var result = await _channel.invokeMethod("setRenderView", {"id": viewID});
    return _liveCodeWithResult(result);
  }

  /// Set the camera mirror type
  ///
  /// **Parameter:**
  ///
  /// `mirrorType` [V2TXLiveMirrorType]
  /// - [V2TXLiveMirrorType.v2TXLiveMirrorTypeAuto]  Default value: The default image type. In this case, the front camera is mirrored, and the rear camera is not
  /// - [V2TXLiveMirrorType.v2TXLiveMirrorTypeEnable]  Both the front camera and the rear camera are switched to mirror mode
  /// - [V2TXLiveMirrorType.v2TXLiveMirrorTypeDisable] Both the front camera and the rear camera are switched to non-mirror mode
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderMirror(V2TXLiveMirrorType mirrorType) async {
    var result = await _channel.invokeMethod(
        'setRenderMirror', {"mirrorType": mirrorType.index});
    return _liveCodeWithResult(result);
  }

  ///
  /// Set the video encoding image
  ///
  /// Encoding mirroring only affects the video effect that viewers see.
  ///
  /// **Parameter:**
  ///
  /// `mirror` Whether it is mirrored
  /// - false Default value: The player sees a non-mirror image
  /// - true: What the player sees is a mirror image
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setEncoderMirror(bool mirror) async {
    var result = await _channel.invokeMethod(
        'setEncoderMirror', {"mirror": mirror});
    return _liveCodeWithResult(result);
  }

  ///
  /// Set the rotation angle of the local camera preview screen
  ///
  /// Only the local preview screen is rotated, and the pushed image is not affected.
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

  /// Turn on your local camera
  ///
  /// Note: startVirtualCamera, startCamera, startScreenCapture, only one of them can be uplink under the same Pusher instance, and the three are overlay relationships. For example, startCamera is called first, and then startVirtualCamera is called. In this case, the camera is paused and the image stream is started
  ///
  /// **Parameter:**
  ///
  /// frontCamera Specifies whether the camera orientation is front-facing
  /// - true Default: Switch to the front-facing camera
  /// - false: Switch to the rear camera
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startCamera(bool frontCamera) async {
    var result = await _channel.invokeMethod(
        'startCamera', {"frontCamera": frontCamera});
    return _liveCodeWithResult(result);
  }

  /// Turn off your local camera
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<void> stopCamera() async {
    return await _channel.invokeMethod('stopCamera', {});
  }

  ///
  /// Turn on the microphone
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startMicrophone() async {
    var result = await _channel.invokeMethod('startMicrophone', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Turn off the microphone
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopMicrophone() async {
    var result = await _channel.invokeMethod('stopMicrophone', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Enable image ingestion
  ///
  /// Note: startVirtualCamera, startCamera, startScreenCapture, only one of them can be uplink under the same Pusher instance, and the three are overlay relationships. For example, startCamera is called first, and then startVirtualCamera is called. In this case, the camera is paused and the image stream is started
  ///
  /// **Parameter:**
  ///
  /// `type` network, file
  ///
  /// `imageUrl` Image url
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startVirtualCamera(String type, String imageUrl) async {
    var result = await _channel.invokeMethod(
        'startVirtualCamera',
        {"type": type, "imageUrl": imageUrl});
    return _liveCodeWithResult(result);
  }

  ///
  /// Disable image ingestion
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopVirtualCamera() async {
    var result = await _channel.invokeMethod('stopVirtualCamera', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Turn on screen capture
  ///
  /// Note: startVirtualCamera, startCamera, startScreenCapture, only one of them can be uplink under the same Pusher instance, and the three are overlay relationships. For example, startCamera is called first, and then startVirtualCamera is called. In this case, the camera is paused and the image stream is started
  ///
  /// **Parameter:**
  ///
  /// `appGroup`  This parameter is only valid for iOS and can be ignored for Android. It is the Application Group Identifier that is shared by the main application and the broadcast process
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startScreenCapture(String appGroup) async {
    var result = await _channel.invokeMethod('startScreenCapture', {"appGroup": appGroup});
    return _liveCodeWithResult(result);
  }

  ///
  /// Turn off screen capture
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopScreenCapture() async {
    var result = await _channel.invokeMethod('stopScreenCapture', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Pause the audio stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> pauseAudio() async {
    var result = await _channel.invokeMethod('pauseAudio', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Resume the audio stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> resumeAudio() async {
    var result = await _channel.invokeMethod('resumeAudio', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Pause the video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> pauseVideo() async {
    var result = await _channel.invokeMethod('pauseVideo', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Resume the video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> resumeVideo() async {
    var result = await _channel.invokeMethod('resumeVideo', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Starts ingesting audio and video data
  ///
  /// **Parameter:**
  ///
  /// `url` The destination address of the stream ingest server can be used at any streaming server
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: The operation succeeds and the destination endpoint is connected
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: The operation failed and the URL was invalid
  /// - V2TXLIVE_ERROR_INVALID_LICENSE: The operation fails, the license is invalid, and the authentication fails
  /// - V2TXLIVE_ERROR_REFUSED: If the operation fails, RTC does not support pushing and pulling the same StreamId on the same device at the same time
  Future<V2TXLiveCode> startPush(String url) async {
    var result = await _channel.invokeMethod('startPush', {"url": url});
    return _liveCodeWithResult(result);
  }

  ///
  /// Stop pushing audio and video data
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopPush() async {
    var result = await _channel.invokeMethod('stopPush', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Whether the stream ingest is pushing
  ///
  /// **Return:**
  /// - 1: Ingesting is in progress
  /// - 0: Ingest has been stopped
  Future<V2TXLiveCode> isPushing() async {
    var result = await _channel.invokeMethod('isPushing', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Set the ingest audio quality
  ///
  /// **Parameter:**
  ///
  /// `quality` Audio quality [V2TXLiveAudioQuality]
  /// - [V2TXLiveAudioQuality.v2TXLiveAudioQualityDefault] Default value: General
  /// - [V2TXLiveAudioQuality.v2TXLiveAudioQualitySpeech] Voice
  /// - [V2TXLiveAudioQuality.v2TXLiveAudioQualityMusic]  Music
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: During the ingest process, the sound quality cannot be adjusted
  Future<V2TXLiveCode> setAudioQuality(V2TXLiveAudioQuality quality) async {
    var result = await _channel.invokeMethod(
        'setAudioQuality', {"quality": quality.index});
    return _liveCodeWithResult(result);
  }

  ///
  /// Set the encoding parameters for streaming video
  ///
  /// **Parameter:**
  ///
  /// `param` Video encoding parameters [V2TXLiveVideoEncoderParam]
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setVideoQuality(V2TXLiveVideoEncoderParam param) async {
    var result = await _channel.invokeMethod(
        'setVideoQuality', param.toJson());
    return _liveCodeWithResult(result);
  }

  /// Get the sound management object [TXAudioEffectManager], you can set the background music, short sound effects and life effects.
  TXAudioEffectManager getAudioEffectManager() {
    _channel.invokeMethod('getAudioEffectManager');
    return _audioEffectManager;
  }

  /// Get a beauty management object [TXBeautyManager], you can modify the beauty, filter, redness and other parameters
  TXBeautyManager getBeautyManager() {
    _channel.invokeMethod('getBeautyManager');
    return _beautyManager;
  }

  /// Get a device management object [TXDeviceManager], you can modify the beauty, filter, redness and other parameters
  TXDeviceManager getDeviceManager() {
    _channel.invokeMethod('getDeviceManager');
    return _deviceManager;
  }

  ///
  /// Capture the local image during stream ingest
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: Stream ingest has been stopped, and screenshot operations are not allowed
  Future<V2TXLiveCode> snapshot() async {
    var result = await _channel.invokeMethod('snapshot', {});
    return _liveCodeWithResult(result);
  }

  ///
  /// Set the watermark of the streamer. By default, watermarks are not turned on.
  ///
  /// **Parameter:**
  ///
  /// `type` network, file
  ///
  /// `image` Watermark the image. If the value is null, it is equivalent to disabling the watermark
  ///
  /// `x` Unified X coordinate of the watermark position. Value range: `[0,1]`
  ///
  /// `y` Unified Y coordinate of the watermark position. Value range: `[0,1]`
  ///
  /// `scale` The zoom of the watermark image, which can range from 0 to 1 floating-point number.
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setWatermark(String type, String image, double x,
      double y, double scale) async {
    var result = await _channel.invokeMethod('setWatermark', {
      "type": type,
      "image": image,
      "x": x.toString(),
      "y": y.toString(),
      "scale": scale.toString()
    });
    return _liveCodeWithResult(result);
  }

  ///
  /// Enables the capture volume prompt
  ///
  /// After this is enabled, you can get the SDK's evaluation of the volume value in the [V2TXLivePusherListenerType.onMicrophoneVolumeUpdate] callback.
  ///
  /// **Parameter:**
  ///
  /// `intervalMs` determines the trigger interval of the [V2TXLivePusherListenerType.onMicrophoneVolumeUpdate] callback, the unit is ms, the minimum interval is 100ms, if it is less than or equal to 0, the callback will be disabled, it is recommended to set it to 300ms; Default value: 0, not enabled
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableVolumeEvaluation(int intervalMs) async {
    var result = await _channel.invokeMethod(
        'enableVolumeEvaluation', {"intervalMs": intervalMs,});
    return _liveCodeWithResult(result);
  }

  ///
  /// Enable/disable custom video processing
  ///
  /// **Parameter:**
  ///
  /// `enable` true: Enabled; false: Disabled. Default: false
  ///
  /// `key` Object of the beautification instance: key
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_NOT_SUPPORTED: Unsupported formats
  Future<V2TXLiveCode> enableCustomVideoProcess(bool enable) async {
    var result = await _channel.invokeMethod('enableCustomVideoProcess', {
      "enable": enable
    });
    return _liveCodeWithResult(result);
  }

  ///
  /// Turn on/off custom video capture
  ///
  /// Note:
  /// - In this mode, the SDK no longer captures images from the camera, only retaining the encoding and sending capabilities.
  /// - It needs to be called before [startPush] for it to take effect.
  ///
  /// **Parameter:**
  ///
  /// `enable` true: enables custom collection. false: disables custom collection. Default: false
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableCustomVideoCapture(bool enable) async {
    var result = await _channel.invokeMethod(
        'enableCustomVideoCapture', {"enable": enable});
    return _liveCodeWithResult(result);
  }

  ///
  /// Turn on/off custom audio capture
  ///
  /// Note:
  /// - In this mode, the SDK no longer captures sound from the microphone, only retaining the encoding and sending capabilities.
  /// - It needs to be called before [startPush] for it to take effect.
  ///
  /// **Parameter:**
  ///
  /// `enable` true: Enable custom collection; false: Disables custom collection. Default: false
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableCustomAudioCapture(bool enable) async {
    var result = await _channel.invokeMethod(
        'enableCustomAudioCapture', {"enable": enable});
    return _liveCodeWithResult(result);
  }

  ///
  /// In the custom video capture mode, the collected video data is sent to the SDK
  ///
  /// Note:
  /// - In this mode, the SDK no longer collects camera data, and only retains the encoding and sending functions.
  /// - You need to call [enableCustomVideoCapture] before [startPush] to enable custom capture.
  ///
  /// **Parameter:**
  ///
  /// `videoFrame` Video frame data sent to the SDK [V2TXLiveVideoFrame]
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: The sending failed and the video frame data is invalid
  /// - V2TXLIVE_ERROR_REFUSED: If the sending fails, you must call [enableCustomVideoCapture] to enable custom video capture.
  Future<V2TXLiveCode> sendCustomVideoFrame(V2TXLiveVideoFrame videoFrame) async {
    var result = await _channel.invokeMethod("V2TXLiveAudioFrame", videoFrame.toJson());
    return _liveCodeWithResult(result);
  }

  ///
  /// In the custom audio collection mode, the collected audio data is sent to the SDK
  ///
  /// Note:
  /// - In this mode, the SDK no longer collects microphone data, and only retains the encoding and sending functions.
  /// - You need to call [enableCustomAudioCapture] before [startPush] to enable custom capture.
  ///
  /// **Parameter:**
  ///
  /// `audioFrame` Audio frame data sent to the SDK [V2TXLiveAudioFrame]
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: If the sending fails, you must first call [enableCustomAudioCapture] to enable custom audio capture
  Future<V2TXLiveCode> sendCustomAudioFrame(V2TXLiveAudioFrame audioFrame) async {
    var result = await _channel.invokeMethod("V2TXLiveAudioFrame", audioFrame.toJson());
    return _liveCodeWithResult(result);
  }

  ///
  /// Send an SEI message
  ///
  /// The player receives the message via the [V2TXLivePlayerListenerType.onReceiveSeiMessage] callback.
  ///
  /// **Parameter:**
  ///
  /// `payloadType`  Data type, 5, 242 supported. Recommended: 242
  ///
  /// `data`        Data to be sent
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> sendSeiMessage(int payloadType, Uint8List data) async {
    var result = await _channel.invokeMethod('sendSeiMessage',
        {"payloadType": payloadType, "data": data});
    return _liveCodeWithResult(result);
  }

  /// Display the dashboard
  ///
  /// **Parameter:**
  ///
  /// `isShow` Whether it is displayed or not. Default: false
  Future<V2TXLiveCode> showDebugView(bool isShow) async {
    var result = await _channel.invokeMethod(
        'showDebugView', {"isShow": isShow});
    return _liveCodeWithResult(result);
  }

  /// Call the high-level API interface of V2TXLivePusher
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

  ///
  /// Set the parameters for MixTranscoding in the cloud
  ///
  /// If you enable Enable Bypass Streaming on the Feature Configuration page in the real-time audio and video [Console](https://console.cloud.tencent.com/trtc/),
  /// Each screen in the room will have a default live stream [CDN address](https://cloud.tencent.com/document/product/647/16826)
  ///
  /// There may be more than one streamer in a live stream, and each streamer has their own picture and sound, but for CDN viewers, they only need to live stream all the way
  /// Therefore, you need to mix multiple audio and video streams into a standard live stream, which requires transcoding
  ///
  /// When you call this API, the SDK sends a command to Tencent Cloud's transcoding server to mix multiple audio and video streams in the room into one.
  /// You can use the mixStreams parameter to adjust the position of each image and whether to mix only sound, and you can also use parameters such as videoWidth, videoHeight, and videoBitrate to control the encoding parameters of the mixed audio and video streams
  ///
  /// <pre>
  /// 【Video1】=> Decode ====> \
  ///                         \
  /// 【Video2】=> Decode =>  video mixing => Encode => 【Mixed Video】
  ///                         /
  /// 【Video3】=> Decode ====> /
  ///
  /// 【Audio1】=> Decode ====> \
  ///                         \
  /// 【Audio2】=> Decode =>  audio mixing => Encode => 【Mixed Audio】
  ///                         /
  /// 【Audio3】=> Decode ====> /
  /// </pre>
  ///
  /// Reference: [Cloud Mixtranscoding](https://cloud.tencent.com/document/product/647/16827)
  ///
  /// Note:
  /// - Only RTC mode is supported
  /// - Cloud transcoding will introduce a certain CDN viewing delay, which will increase by about 1-2 seconds
  /// - The user who calls this function will mix the multi-channel image in the microphone connection to the current screen or the streamId specified in the config
  /// - Please note that if you are still in the room and no longer need to mix streams, be sure to pass null to cancel, because after you initiate stream mixing, the cloud stream mixing module will start working, and failure to cancel the mix in time may cause unnecessary billing losses
  /// - Rest assured, the mix-in status will be automatically canceled when you check out
  ///
  /// **Parameter:**
  ///
  /// `config` Please refer to [V2TXLiveTranscodingConfig]. If null is passed, the cloud blending transcoding is canceled
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: If stream ingest is not enabled, you are not allowed to set the MixTranscoding parameter
  Future<V2TXLiveCode> setMixTranscodingConfig(V2TXLiveTranscodingConfig? config) async {
    var result = await _channel.invokeMethod('setMixTranscodingConfig',
        {"config": config?.toJson() ?? {}});
    return _liveCodeWithResult(result);
  }
}
