import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'v2_tx_live_code.dart';
import 'v2_tx_live_def.dart';

enum V2TXLivePremierObserverType {
  /// Customize the log output callback interface
  ///
  /// **Parameter:**
  ///
  /// `level` Log level
  ///
  /// `log` Log content
  onLog,

  /// setLicence interface callback
  ///
  /// **Parameter:**
  ///
  /// `reason` Set the licence failure reason
  ///
  /// `result` Set licence result 0 succeeds and negative fails
  onLicenceLoaded,
}

typedef V2TXLivePremierObserver<P> = void Function(V2TXLivePremierObserverType type, P? params);

class V2TXLivePremier {

  V2TXLivePremier._privateConstructor();

  static final V2TXLivePremier _instance = V2TXLivePremier
      ._privateConstructor();
  late MethodChannel _channel;
  late V2TXLivePremierObserver? _observer;

  factory V2TXLivePremier(){
    _instance._initMethodChannel();
    return _instance;
  }

  _initMethodChannel() {
    _channel = const MethodChannel("live_cloud_premier");
    _channel.setMethodCallHandler((MethodCall call) async {
      debugPrint("MethodCallHandler method: ${call.method}");
      var arguments = call.arguments;
      if (arguments is Map) {
        debugPrint("arguments is Map: $arguments");
      } else {
        debugPrint("arguments isn't Map: $arguments");
      }
      if (call.method == "onPremierListener") {
        String typeStr = arguments['type'];
        var params = arguments['params'];
        debugPrint("on Premier Listener: type:$typeStr");
        V2TXLivePremierObserverType? callType;
        for (var subType in V2TXLivePremierObserverType.values) {
          if (subType.toString().replaceFirst(
              "V2TXLivePremierObserverType.", "") == typeStr) {
            callType = subType;
            break;
          }
        }
        if (callType != null && _observer != null) {
          _observer!(callType, params);
        }
      } else {
        debugPrint("on Player Listener: MethodNotImplemented ${call.method}");
      }
    });
  }

  /// Set the authorization license for the SDK
  /// Document address: https://cloud.tencent.com/document/product/454/34750
  ///
  /// **Parameter:**
  ///
  /// `url` licence url
  ///
  /// `key` licence key
  static Future<void> setLicence(String url, String key) async {
    await V2TXLivePremier()._channel.invokeMethod(
        "setLicence", {"url": url, "key": key});
  }

  /// Obtain the SDK version
  static Future<String> getSDKVersionStr() async {
    var version = await V2TXLivePremier()._channel.invokeMethod(
        "getSDKVersionStr");
    return version;
  }

  /// Set the V2TXLivePremier callback API
  static Future<void> setObserver(V2TXLivePremierObserver? observer) async {
    V2TXLivePremier()._observer = observer;
  }

  /// Set the configuration information for the log
  static Future<V2TXLiveCode> setLogConfig(V2TXLiveLogConfig config) async {
    var code = await V2TXLivePremier()._channel.invokeMethod(
        "setLogConfig", {"config": config.toJson()});
    if (code is V2TXLiveCode) {
      return code;
    } else {
      return V2TXLIVE_ERROR_FAILED;
    }
  }

  /// Set up the SDK access environment
  ///
  /// Note: If your application does not have special requirements, please do not call this API to set up.
  ///
  /// **Parameter:**
  ///
  /// `env` Currently, two parameters are supported: "default" and "GDPR".
  /// - default: The default environment, the SDK will find the best access point around the world for access.
  /// - GDPR: All audio and video data and quality statistics will not pass through servers in Chinese mainland.
  static Future<V2TXLiveCode> setEnvironment(String env) async {
    var code = await V2TXLivePremier()._channel.invokeMethod(
        "setEnvironment", {"env": env});
    if (code is V2TXLiveCode) {
      return code;
    } else {
      return V2TXLIVE_ERROR_FAILED;
    }
  }

  /// Set up the SDK socks5 proxy configuration
  ///
  /// **Parameter:**
  ///
  /// `host` The address of the SOCKS5 proxy server
  ///
  /// `port` The port of the SOCKS5 proxy server
  ///
  /// `username` The username of the SOCKS5 proxy server
  ///
  /// `password` The password of the SOCKS5 proxy server
  ///
  /// `config` For details, please refer to  [V2TXLiveSocks5ProxyConfig]
  static Future<V2TXLiveCode> setSocks5Proxy(String host, int port,
      String username, String password,
      V2TXLiveSocks5ProxyConfig config) async {
    var code = await V2TXLivePremier()._channel.invokeMethod("setSocks5Proxy", {
      "host": host,
      "port": port,
      "username": username,
      "password": password,
      "config": config.toJson()
    });
    if (code is V2TXLiveCode) {
      return code;
    } else {
      return V2TXLIVE_ERROR_FAILED;
    }
  }

  /// Set the user ID
  ///
  /// **Parameter:**
  ///
  /// `userId` The ID of the user/device maintained by the service side.
  static Future<V2TXLiveCode> setUserId(String userId) async {
    var code = await V2TXLivePremier()._channel.invokeMethod(
        "setUserId", {"userId": userId});
    if (code is V2TXLiveCode) {
      return code;
    } else {
      return V2TXLIVE_ERROR_FAILED;
    }
  }

  /// Config PIP mode of each player
  ///
  /// Changing the mode will not affect any existed player, thus it is prefered
  /// to setup a global config before streaming any live room
  ///
  /// [enable]`true` turns on PIP mode. The actual effect of turning on PIP mode
  /// depends on the implementation of navite, which is not currently supported on
  /// the Android platform.
  static Future<V2TXLiveCode> enablePictureInPictureMode(bool enable) async {
    final code = await V2TXLivePremier()._channel.invokeMethod(
      'enablePictureInPictureMode',
      {'enable': enable},
    );

    return code is V2TXLiveCode ? code : V2TXLIVE_ERROR_FAILED;
  }
}