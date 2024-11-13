//
//  V2TXLivePlayerPlugin.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/20.
//

import Foundation
import TXLiteAVSDK_Professional
import Flutter

class V2TXLivePlayerPlugin: NSObject {
    private let channel: FlutterMethodChannel
    private var viewProvider: PlatformViewProvider? {
        return pluginManager?.viewFactory
    }
    weak var pluginManager: TXLivePluginManager?
    private let player: V2TXLivePlayer
    
    let identifier: String
    
    init(identifier: String, pluginManager: TXLivePluginManager) {
        self.identifier = identifier
        self.pluginManager = pluginManager
        self.channel = FlutterMethodChannel(name: "player_\(identifier)", binaryMessenger: pluginManager.messenger)
        self.player = V2TXLivePlayer()
        super.init()
        self.player.setObserver(self)
        self.channel.setMethodCallHandler(handle)
    }
    
    func destroy() {
        Logger.info(content: "V2TXLivePlayerPlugin\(identifier) destroy")
        self.player.setObserver(nil)
        self.channel.setMethodCallHandler(nil)
    }
    
    deinit {
        Logger.info(content: "V2TXLivePlayerPlugin\(identifier) deinit")
        debugPrint("V2TXLivePlayerPlugin deinit")
    }
}

extension V2TXLivePlayerPlugin {
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Logger.flutterMethodInfo(call)
        let selectorName = "\(call.method)WithCall:result:"
        let selector = Selector(selectorName)
        debugPrint("V2TXLivePlayerPlugin Received method channel name: \(call.method)")
        guard self.responds(to: selector) else {
            Logger.error(content: "V2TXLivePlayerPlugin \(call.method) FlutterMethodNotImplemented")
            result(FlutterMethodNotImplemented)
            return
        }
        let block: @convention(block) (Any?) -> () = result
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.perform(selector, with: call, with: block)
        }
        
    }
}

extension V2TXLivePlayerPlugin {
    /// 设置本地摄像头预览视图的ID
    @objc
    func setRenderView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewProvider = self.viewProvider else {
            FlutterResultUtils.handle(code: .unknown, msg: "native view provider is not init. please check register method", result: result)
            return
        }
        let key = "id"
        guard let viewID = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.int64Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        if let platformView = viewProvider.getViewBy(viewID: viewID) {
            let code = player.setRenderView(platformView.view())
            result(NSNumber(value: code.rawValue))
        } else {
            FlutterResultUtils.handle(code: .platformViewNotFound, msg: "view not init, please init.", result: result)
        }
    }
    
    /// 摄像头镜像类型
    @objc
    func setRenderRotation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "rotation"
        guard let rotationValue = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let rotation = V2TXLiveRotation(rawValue: rotationValue) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            
            return
        }
        let code = player.setRenderRotation(rotation)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置画面的填充模式。
    @objc
    func setRenderFillMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "mode"
        guard let modeValue = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let mode = V2TXLiveFillMode(rawValue: modeValue) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            
            return
        }
        let code = player.setRenderFillMode(mode)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开始播放音视频流。
    @objc
    func startLivePlay(call: FlutterMethodCall, result: @escaping FlutterResult) {
        setFramework()
        let key = "url"
        guard let url = MethodUtils.getMethodParams(call: call, key: key, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = player.startLivePlay(url)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 停止播放音视频流。
    @objc
    func stopPlay(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.stopPlay()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 播放器是否正在播放中。
    @objc
    func isPlaying(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.isPlaying()
        result(NSNumber(value: code))
    }
    
    /// 暂停播放器的音频流
    @objc
    func pauseAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.pauseAudio()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 恢复播放器的音频流。
    @objc
    func resumeAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.resumeAudio()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 暂停播放器的视频流。
    @objc
    func pauseVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.pauseVideo()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 恢复播放器的视频流。
    @objc
    func resumeVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.resumeVideo()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置播放器音量。
    @objc
    func setPlayoutVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "volume"
        guard let volume = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.uintValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = player.setPlayoutVolume(volume)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置播放器缓存自动调整的最小和最大时间 ( 单位：秒 )。
    @objc
    func setCacheParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let minTimeKey = "minTime"
        guard let minTime = MethodUtils.getMethodParams(call: call, key: minTimeKey, resultType: NSString.self)?.floatValue
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: minTimeKey, result: result)
            return
        }
        let maxTimeKey = "maxTime"
        guard let maxTime = MethodUtils.getMethodParams(call: call, key: maxTimeKey, resultType: NSString.self)?.floatValue
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: maxTimeKey, result: result)
            return
        }
        let code = player.setCacheParams(CGFloat(minTime), maxTime: CGFloat(maxTime))
        result(NSNumber(value: code.rawValue))
    }
    
    /// 启用播放音量大小提示。
    @objc
    func enableVolumeEvaluation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "intervalMs"
        guard let intervalMs = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.uintValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = player.enableVolumeEvaluation(intervalMs)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 截取播放过程中的视频画面。
    @objc
    func snapshot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = player.snapshot()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开启/关闭对视频帧的监听回调。
    @objc
    func enableObserveVideoFrame(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enableKey = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: enableKey, resultType:      NSNumber.self)?.boolValue
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: enableKey, result: result)
            return
        }
        let pixelFormatKey = "pixelFormat"
        guard let pixelFormatValue = MethodUtils.getMethodParams(call: call, key: pixelFormatKey, resultType: NSNumber.self)?.intValue
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: pixelFormatKey, result: result)
            return
        }
        guard let pixelFormat = V2TXLivePixelFormat(rawValue: pixelFormatValue)
        else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: pixelFormatKey, result: result)
            
            return
        }
        let bufferTypeKey = "bufferType"
        guard let bufferValue  = MethodUtils.getMethodParams(call: call, key: bufferTypeKey, resultType: NSNumber.self)?.intValue
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: bufferTypeKey, result: result)
            return
        }
        guard let bufferType = V2TXLiveBufferType(rawValue: bufferValue)
        else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: bufferTypeKey, result: result)
            
            return
        }
        
        let code = player.enableObserveVideoFrame(enable, pixelFormat: pixelFormat, bufferType: bufferType)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开启接收 SEI 消息
    @objc
    func enableReceiveSeiMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enableKey = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: enableKey, resultType: NSNumber.self)?.boolValue
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: enableKey, result: result)
            return
        }
        let payloadTypeKey = "payloadType"
        guard let payloadType = MethodUtils.getMethodParams(call: call, key: payloadTypeKey, resultType: NSNumber.self)?.int32Value
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: payloadTypeKey, result: result)
            return
        }
        let code = player.enableReceiveSeiMessage(enable, payloadType: payloadType)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 是否显示播放器状态信息的调试浮层。
    @objc
    func showDebugView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "isShow"
        guard let isShow = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        player.showDebugView(isShow)
    }
    
    /// 调用 V2TXLivePlayer 的高级 API 接口。
    @objc
    func setProperty(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let key = MethodUtils.getMethodParams(call: call, key: "key", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "key", result: result)
            return
        }
        guard let value = MethodUtils.getMethodParams(call: call, key: "value", resultType: NSObject.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "value", result: result)
            return
        }
        let code = player.setProperty(key, value: value)
        result(NSNumber(value: code.rawValue))
    }

     /// 开启画中画模式
     @objc
     func enablePictureInPicture(call: FlutterMethodCall, result: FlutterResult?) {
         let enableKey = "enable"
         guard let enable = MethodUtils.getMethodParams(call: call, key: enableKey, resultType: NSNumber.self)?.boolValue
         else {
             FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: enableKey, result: result)
             return
         }
         let code = player.enablePicture(inPicture: enable)
         result?(NSNumber(value: code.rawValue))
     }
}

// MARK: - V2TXLivePlayerObserver回调
extension V2TXLivePlayerPlugin: V2TXLivePlayerObserver  {
    /// 直播播放器错误通知，播放器出现错误时，会回调该通知
    func onError(_ player: V2TXLivePlayerProtocol, code: V2TXLiveCode, message msg: String, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onError, params: ["errCode": code.rawValue, "errMsg": msg , "extraInfo": extraInfo as Any])
    }
    
    /// 直播播放器警告通知
    func onWarning(_ player: V2TXLivePlayerProtocol, code: V2TXLiveCode, message msg: String, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onWarning, params: ["errCode": code.rawValue, "errMsg": msg , "extraInfo": extraInfo as Any])
    }
    
    /// 直播播放器分辨率变化通知
    public func onVideoResolutionChanged(_ player: V2TXLivePlayerProtocol, width: Int, height: Int) {
        invokeListener(type: .onVideoResolutionChanged, params: ["width": width, "height": height])
    }
    
    /// 已经成功连接到服务器
    func onConnected(_ player: V2TXLivePlayerProtocol, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onConnected, params: ["extraInfo": extraInfo as Any])
    }
    
    /// 视频播放事件
    func onVideoPlaying(_ player: V2TXLivePlayerProtocol, firstPlay: Bool, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onVideoPlaying, params: ["firstPlay": firstPlay, "extraInfo": extraInfo as Any])
    }
    
    /// 音频播放事件
    func onAudioPlaying(_ player: V2TXLivePlayerProtocol, firstPlay: Bool, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onAudioPlaying, params: ["firstPlay": firstPlay, "extraInfo": extraInfo as Any])
    }
    
    /// 视频加载事件
    public func onVideoLoading(_ player: V2TXLivePlayerProtocol, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onVideoLoading, params: ["extraInfo": extraInfo as Any])
        
    }
    
    /// 音频加载事件
    public func onAudioLoading(_ player: V2TXLivePlayerProtocol, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onAudioLoading, params: ["extraInfo": extraInfo as Any])
        
    }
    
    /// 播放器音量大小回调
    public func onPlayoutVolumeUpdate(_ player: V2TXLivePlayerProtocol, volume: Int) {
        invokeListener(type: .onPlayoutVolumeUpdate, params: ["volume": volume])
        
    }
    
    /// 直播播放器统计数据回调
    public func onStatisticsUpdate(_ player: V2TXLivePlayerProtocol, statistics: V2TXLivePlayerStatistics) {
        invokeListener(type: .onStatisticsUpdate, params: [
            "appCpu": statistics.appCpu,
            "systemCpu": statistics.systemCpu,
            "width": statistics.width,
            "height": statistics.height,
            "fps": statistics.fps,
            "videoBitrate": statistics.videoBitrate,
            "audioBitrate": statistics.audioBitrate,
        ])
    }
    
    /// 截图回调
    public func onSnapshotComplete(_ player: V2TXLivePlayerProtocol, image: UIImage?) {
        guard let imageData = image?.pngData() else {
            return
        }
        let flutterData = FlutterStandardTypedData(bytes: imageData)
        invokeListener(type: .onSnapshotComplete,
                       params: ["image": flutterData])
    }
    
    /// 自定义视频渲染回调
    public func onRenderVideoFrame(_ player: V2TXLivePlayerProtocol, frame videoFrame: V2TXLiveVideoFrame) {
        invokeListener(type: .onRenderVideoFrame, params: ["videoFrame": VideoFrameUtils.handleVideoFrame(videoFrame)])
    }
    
    /// 收到 SEI 消息的回调，发送端通过 {@link V2TXLivePusher} 中的 `sendSeiMessage` 来发送 SEI 消息。
    public func onReceiveSeiMessage(_ player: V2TXLivePlayerProtocol, payloadType: Int32, data: Data) {
        invokeListener(type: .onReceiveSeiMessage,
                       params: ["payloadType": payloadType, "data": FlutterStandardTypedData(bytes: data)])
    }

    /// 画中画状态变更回调
    public func onPicture(inPictureStateUpdate player: V2TXLivePlayerProtocol, state: V2TXLivePictureInPictureState, message msg: String, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onPictureInPictureStateUpdate, params: ["state": state.rawValue, "message": msg , "extraInfo": extraInfo as Any])
    }
}

// MARK: - Private setFramework
extension V2TXLivePlayerPlugin {
    
    private func setFramework() {
        let jsonDic: [String: Any] = ["api": "setFramework",
                                      "params": ["framework": 23,
                                                 "component": 1]]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        player.setProperty("setFramework", value: (jsonString as NSString))
    }
}

// MARK: - V2TXLivePlayerObserver Flutter回调
extension V2TXLivePlayerPlugin {
    func invokeListener(type: V2TXLivePlayerObserverType, params: Any? = nil) {
        Logger.info(content: "V2TXLivePlayerPlugin received observer \(type.rawValue)")
        var arguments: [String: Any] = [:]
        arguments["type"] = type.rawValue
        if let paramsValue = params {
            arguments["params"] = paramsValue
        }
        channel.invokeMethod("onPlayerListener", arguments: arguments)
    }
}
