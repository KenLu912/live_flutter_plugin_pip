//
//  V2TXLivePusherPlugin.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/20.
//

import Foundation
import AVFoundation
import TXLiteAVSDK_Professional
import Flutter
import TXCustomBeautyProcesserPlugin

protocol PlatformViewProvider: AnyObject {
    func getViewBy(viewID: Int64) -> FlutterPlatformView?
}

class V2TXLivePusherPlugin: NSObject {
    
    let identifier: String
    let customBeautyQueue: DispatchQueue = DispatchQueue(label: "CustomBeautyQueue")
    private var beautyInstance: ITXCustomBeautyProcesser? = nil
    private let channel: FlutterMethodChannel
    weak var pluginManager: TXLivePluginManager?
    private let pusher: V2TXLivePusher
    
    private var viewProvider: PlatformViewProvider? {
        return pluginManager?.viewFactory
    }
    private var messenger: FlutterBinaryMessenger? {
        return pluginManager?.messenger
    }
    /// 美颜管理器
    var beautyManager: TXBeautyManager {
        return pusher.getBeautyManager()
    }
    /// 音效管理器
    var audioEffectManager: TXAudioEffectManager {
        return pusher.getAudioEffectManager()
    }
    /// 设备管理器
    var deviceManager: TXDeviceManager {
        return pusher.getDeviceManager()
    }
    
    init(identifier: String,
         mode: V2TXLiveMode,
         pluginManager: TXLivePluginManager) {
        
        self.identifier = identifier
        self.pusher = V2TXLivePusher(liveMode: mode)
        self.pluginManager = pluginManager
        self.channel = FlutterMethodChannel(name: "pusher_\(identifier)", binaryMessenger: pluginManager.messenger)
        super.init()
        self.pusher.setObserver(self)
        self.channel.setMethodCallHandler(handle)
    }
    
    func destroy() {
        Logger.info(content: "V2TXLivePusherPlugin\(identifier) destroy")
        self.pusher.setObserver(nil)
        self.channel.setMethodCallHandler(nil)
        beautyInstance = nil
    }
    
    deinit {
        Logger.info(content: "V2TXLivePusherPlugin\(identifier) deinit")
        debugPrint("V2TXLivePusherPlugin deinit")
    }
}

// MARK: - Flutter 消息回调
extension V2TXLivePusherPlugin {
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Logger.flutterMethodInfo(call)
        let selectorName = "\(call.method)WithCall:result:"
        let selector = NSSelectorFromString(selectorName)
        debugPrint("V2TXLivePusherPlugin Received method channel name: \(call.method)")
        guard self.responds(to: selector) else {
            Logger.error(content: "V2TXLivePusherPlugin \(call.method) FlutterMethodNotImplemented")
            result(FlutterMethodNotImplemented)
            return
        }
        let block: @convention(block) (Any?) -> () = result
        // 消息和响应以异步的形式进行传递，以确保用户界面能够保持响应。
        // Flutter 是通过 Dart 异步发送消息的。即便如此，当你调用一个平台方法时，也需要在主线程上做调用。在
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.perform(selector, with: call, with: block)
        }
        
    }
}

// MARK: - Private: V2TXLivePusher 调用
extension V2TXLivePusherPlugin {
    
    /// 设置推流器回调。
    @objc
    func setObserver(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // TODO: - 回调暂未实现
    }
    
    /// 设置本地摄像头预览镜像。
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
            let code = self.pusher.setRenderView(platformView.view())
            result(NSNumber(value: code.rawValue))
        } else {
            FlutterResultUtils.handle(code: .platformViewNotFound, msg: "view not init, please init.", result: result)
        }
    }
    
    /// 设置本地摄像头预览镜像。
    @objc
    func setRenderMirror(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "mirrorType"
        guard let mirrorType = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let mirror = V2TXLiveMirrorType(rawValue: mirrorType) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.setRenderMirror(mirror)
        result(NSNumber(value: code.rawValue))
    }
    
    
    /// 设置视频编码镜像。
    @objc
    func setEncoderMirror(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "mirror"
        guard let mirror = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.setEncoderMirror(mirror)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置本地摄像头预览画面的旋转角度。
    @objc
    func setRenderRotation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "rotation"
        guard let rotation = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let liveRotation = V2TXLiveRotation(rawValue: rotation) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.setRenderRotation(liveRotation)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 打开本地摄像头。
    @objc
    func startCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "frontCamera"
        guard let frontCamera = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.startCamera(frontCamera)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 关闭本地摄像头。
    @objc
    func stopCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.stopCamera()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 打开麦克风。
    @objc
    func startMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .authorized {
            let code = pusher.startMicrophone()
            result(NSNumber(value: code.rawValue))
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { [weak self](authState) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if authState {
                        let code = self.pusher.startMicrophone()
                        result(NSNumber(value: code.rawValue))
                    } else {
                        result(NSNumber(value: V2TXLiveCode.TXLIVE_WARNING_MICROPHONE_NO_PERMISSION.rawValue))
                    }
                }
            }
        } else {
            result(NSNumber(value: V2TXLiveCode.TXLIVE_WARNING_MICROPHONE_NO_PERMISSION.rawValue))
        }
    }
    
    /// 关闭麦克风
    @objc
    func stopMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.stopMicrophone()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开启图片推流。
    @objc
    func startVirtualCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "type"
        guard let type = MethodUtils.getMethodParams(call: call, key: key, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let imageUrl = MethodUtils.getMethodParams(call: call, key: "imageUrl", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        if type == "network" {
            let queue = DispatchQueue(label: "startVirtualCamera")
            queue.async { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) else {
                    return
                }
                guard let image = UIImage(data: data, scale: 1) else {
                    return
                }
                self.pusher.startVirtualCamera(image)
            }
            result(nil)
        } else if let image = flutterImage(at: imageUrl) {
            let code = pusher.startVirtualCamera(image)
            result(NSNumber(value: code.rawValue))
        } else {
            result(nil)
        }
    }
    
    /// 关闭图片推流。
    @objc
    func stopVirtualCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.stopVirtualCamera()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开始全系统的屏幕分享（该接口支持 iOS 11.0 及以上的 iPhone 和 iPad）。
    @objc
    func startScreenCapture(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "appGroup"
        guard let appGroup = MethodUtils.getMethodParams(call: call, key: key, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        var isCaptured = false
        if #available(iOS 11.0, *) {
            isCaptured = UIScreen.main.isCaptured
        }
        if isCaptured {
            let code = pusher.startScreenCapture(appGroup)
            result(NSNumber(value: code.rawValue))
        } else {
            result(NSNumber(value: V2TXLiveCode.TXLIVE_WARNING_SCREEN_CAPTURE_START_FAILED.rawValue))
        }
    }
    
    /// 关闭屏幕采集。
    @objc
    func stopScreenCapture(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.stopScreenCapture()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 静音本地音频。
    @objc
    func pauseAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.pauseAudio()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 取消静音本地音频。
    @objc
    func resumeAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.resumeAudio()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 暂停推流器的视频流。
    @objc
    func pauseVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.pauseVideo()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 恢复推流器的视频流。
    @objc
    func resumeVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.resumeVideo()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开始音视频数据推流。
    @objc
    func startPush(call: FlutterMethodCall, result: @escaping FlutterResult) {
        setFramework()
        let key = "url"
        guard let url = MethodUtils.getMethodParams(call: call, key: key, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.startPush(url)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 停止推送音视频数据。
    @objc
    func stopPush(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.stopPush()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 当前推流器是否正在推流中。
    @objc
    func isPushing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.isPushing()
        result(NSNumber(value: code))
    }
    
    /// 设置推流音频质量。
    @objc
    func setAudioQuality(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "quality"
        guard let quality = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let audioQuality = V2TXLiveAudioQuality(rawValue: quality) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.setAudioQuality(audioQuality)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置推流视频编码参数
    @objc
    func setVideoQuality(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var key = "videoResolution"
        guard let resolution = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let resolutionType = V2TXLiveVideoResolution(rawValue: resolution) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            return
        }
        key = "videoResolutionMode"
        guard let videoResolutionMode = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let resolutionMode = V2TXLiveVideoResolutionMode(rawValue: videoResolutionMode) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: key, result: result)
            return
        }
        key = "videoFps"
        guard let videoFps = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        key = "videoBitrate"
        guard let videoBitrate = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        key = "minVideoBitrate"
        guard let minVideoBitrate = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let param = V2TXLiveVideoEncoderParam(resolutionType)
        param.minVideoBitrate = minVideoBitrate
        param.videoBitrate = videoBitrate
        param.videoFps = videoFps
        param.videoResolutionMode = resolutionMode
        let code = pusher.setVideoQuality(param)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 获取音效管理对象 {@link TXAudioEffectManager}。
    @objc
    func getAudioEffectManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(NSNumber(value: 0))
    }
    
    /// 获取美颜管理对象 {@link TXBeautyManager}。
    @objc
    func getBeautyManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(NSNumber(value: 0))
    }
    
    /// 获取设备管理对象 {@link TXDeviceManager}。
    @objc
    func getDeviceManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(NSNumber(value: 0))
    }
    
    /// 截取推流过程中的本地画面。
    @objc
    func snapshot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = pusher.snapshot()
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置推流器水印。默认情况下，水印不开启。
    @objc
    func setWatermark(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "type"
        guard let type = MethodUtils.getMethodParams(call: call, key: key, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let imageUrl = MethodUtils.getMethodParams(call: call, key: "image", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let x = MethodUtils.getMethodParams(call: call, key: "x", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let y = MethodUtils.getMethodParams(call: call, key: "y", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        guard let scale = MethodUtils.getMethodParams(call: call, key: "scale", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        if type == "network" {
            let queue = DispatchQueue(label: "setWatermark")
            queue.async { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) else {
                    return
                }
                guard let image = UIImage(data: data, scale: 1) else {
                    return
                }
                self.pusher.setWatermark(image, x: x, y: y, scale: scale)
            }
            result(nil)
        } else if let image = flutterImage(at: imageUrl) {
            let code = pusher.setWatermark(image, x: x, y: y, scale: scale)
            result(NSNumber(value: code.rawValue))
        } else {
            result(nil)
        }
    }
    
    /// 启用采集音量大小提示。
    @objc
    func enableVolumeEvaluation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "intervalMs"
        guard let intervalMs = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.uintValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.enableVolumeEvaluation(intervalMs)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开启/关闭自定义视频处理。
    @objc
    func enableCustomVideoProcess(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        
        guard let customBeautyInstance = TXLivePluginManager.getBeautyInstance() else {
            FlutterResultUtils.handleMethod(code: .valueIsNull, methodName: call.method, paramKey: key, result: result)
            return
        }
        
        customBeautyQueue.async { [weak self] in
            guard let `self` = self else {
                FlutterResultUtils.handleMethod(code: .valueIsNull, methodName: call.method, paramKey: key, result: result)
                return
            }
            if (enable && self.beautyInstance == nil) {
                self.beautyInstance = customBeautyInstance.createCustomBeautyProcesser()
            }
            guard let beautyInstance = self.beautyInstance else {
                FlutterResultUtils.handleMethod(code: .valueIsNull, methodName: call.method, paramKey: key, result: result)
                return
            }
            let pixelFormat = beautyInstance.getSupportedPixelFormat()
            let bufferType = beautyInstance.getSupportedBufferType()
            
            let v2PixelFormat = ConvertBeautyFrame.convertToV2LivePixelFormat(beautyPixelFormat: pixelFormat)
            let v2BufferType = ConvertBeautyFrame.convertToV2LiveBufferType(beautyBufferType: bufferType)
            let code = self.pusher.enableCustomVideoProcess(enable,
                                                            pixelFormat:v2PixelFormat,
                                                            bufferType:v2BufferType)
            DispatchQueue.main.async {
                result(NSNumber(value: code.rawValue))
            }
        }
    }
    
    /// 开启/关闭自定义视频采集。
    @objc
    func enableCustomVideoCapture(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.enableCustomVideoCapture(enable)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 开启/关闭自定义音频采集
    @objc
    func enableCustomAudioCapture(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.enableCustomAudioCapture(enable)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 在自定义视频采集模式下，将采集的视频数据发送到SDK。
    @objc
    func sendCustomVideoFrame(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let pixelFormat = MethodUtils.getMethodParams(call: call, key: "pixelFormat", resultType: Int.self),
              let pixelFormatType = V2TXLivePixelFormat(rawValue: pixelFormat)
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "pixelFormat", result: result)
            return
        }
        guard let buffer = MethodUtils.getMethodParams(call: call, key: "bufferType", resultType: Int.self),
              let bufferType = V2TXLiveBufferType(rawValue: buffer)
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "bufferType", result: result)
            return
        }
        let videoFrame = V2TXLiveVideoFrame()
        videoFrame.pixelFormat = pixelFormatType
        videoFrame.bufferType = bufferType
        if let rotationValue = MethodUtils.getMethodParams(call: call, key: "rotation", resultType: Int.self),
           let rotationType = V2TXLiveRotation(rawValue: rotationValue) {
            videoFrame.rotation = rotationType
        }
        if bufferType == .nsData,
           let data = MethodUtils.getMethodParams(call: call, key: "data", resultType: FlutterStandardTypedData.self)?.data {
            videoFrame.data = data
        }
        if bufferType == .texture,
           let textureId = MethodUtils.getMethodParams(call: call, key: "textureId", resultType: UInt32.self) {
            videoFrame.textureId = GLuint(textureId)
        }
        let code = pusher.sendCustomVideoFrame(videoFrame)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 在自定义音频采集模式下，将采集的音频数据发送到SDK
    @objc
    func sendCustomAudioFrame(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let data = MethodUtils.getMethodParams(call: call, key: "data", resultType: FlutterStandardTypedData.self)?.data
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "data", result: result)
            return
        }
        guard let sampleRate = MethodUtils.getMethodParams(call: call, key: "sampleRate", resultType: Int32.self)
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "sampleRate", result: result)
            return
        }
        guard let channel = MethodUtils.getMethodParams(call: call, key: "channel", resultType: Int32.self)
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "channel", result: result)
            return
        }
        let audioFrame = V2TXLiveAudioFrame()
        audioFrame.data = data
        audioFrame.channel = channel
        audioFrame.sampleRate = sampleRate
        let code = pusher.sendCustomAudioFrame(audioFrame)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 发送 SEI 消息
    @objc
    func sendSeiMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var key = "payloadType"
        guard let payloadType = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.int32Value
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        key = "data"
        guard let data = MethodUtils.getMethodParams(call: call, key: key, resultType: FlutterStandardTypedData.self)?.data
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        let code = pusher.sendSeiMessage(payloadType, data: data)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 显示仪表盘。
    @objc
    func showDebugView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let key = "isShow"
        guard let isShow = MethodUtils.getMethodParams(call: call, key: key, resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: key, result: result)
            return
        }
        pusher.showDebugView(isShow)
        result(NSNumber(value: 0))
    }
    
    /// 调用 V2TXLivePusher 的高级 API 接口。
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
        let code = pusher.setProperty(key, value: value)
        result(NSNumber(value: code.rawValue))
    }
    
    /// 设置云端的混流转码参数
    @objc
    func setMixTranscodingConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let config = MethodUtils.getMethodParams(call: call, key: "config", resultType: [String:Any].self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "config", result: result)
            return
        }
        let code = pusher.setMix(v2TXLiveTranscodingConfig(from: config))
        result(code.rawValue)
    }
}

// MARK: - Private 类型转换
extension V2TXLivePusherPlugin {
    
    private func v2TXLiveTranscodingConfig(from sourceConfig: [String:Any]?) -> V2TXLiveTranscodingConfig? {
        guard let configInfo = sourceConfig, configInfo.count > 0 else { return nil }
        let config = V2TXLiveTranscodingConfig()
        if let videoWidth = configInfo["videoWidth"] as? UInt {
            config.videoWidth = videoWidth
        }
        if let videoHeight = configInfo["videoHeight"] as? UInt {
            config.videoHeight = videoHeight
        }
        if let videoBitrate = configInfo["videoBitrate"] as? UInt {
            config.videoBitrate = videoBitrate
        }
        if let videoFramerate = configInfo["videoFramerate"] as? UInt {
            config.videoFramerate = videoFramerate
        }
        if let videoGOP = configInfo["videoGOP"] as? UInt {
            config.videoGOP = videoGOP
        }
        if let backgroundColor = configInfo["backgroundColor"] as? UInt {
            config.backgroundColor = backgroundColor
        }
        if let backgroundImage = configInfo["backgroundImage"] as? String {
            config.backgroundImage = backgroundImage
        }
        if let audioSampleRate = configInfo["audioSampleRate"] as? UInt {
            config.audioSampleRate = audioSampleRate
        }
        if let audioBitrate = configInfo["audioBitrate"] as? UInt {
            config.audioBitrate = audioBitrate
        }
        if let audioChannels = configInfo["audioChannels"] as? UInt {
            config.audioChannels = audioChannels
        }
        if let outputStreamId = configInfo["outputStreamId"] as? String {
            config.outputStreamId = outputStreamId
        }
        if let mixStreams = configInfo["mixStreams"] as? [[String:Any]] {
            var items = [V2TXLiveMixStream]()
            for item in mixStreams {
                let data = v2TXLiveMixStream(from: item)
                items.append(data)
            }
            config.mixStreams = items
        }
        return config
    }
    
    private func v2TXLiveMixStream(from config: [String:Any]) -> V2TXLiveMixStream {
        let data = V2TXLiveMixStream()
        if let userId = config["userId"] as? String {
            data.userId = userId
        }
        if let streamId = config["streamId"] as? String {
            data.streamId = streamId
        }
        if let x = config["x"] as? Int {
            data.x = x
        }
        if let y = config["y"] as? Int {
            data.y = y
        }
        if let width = config["width"] as? Int {
            data.width = width
        }
        if let height = config["height"] as? Int {
            data.height = height
        }
        if let zOrder = config["zOrder"] as? UInt {
            data.zOrder = zOrder
        }
        if let inputValue = config["inputType"] as? Int, let inputType = V2TXLiveMixInputType(rawValue: inputValue) {
            data.inputType = inputType
        }
        return data
    }
}

// MARK: - Flutter资源文件读取
extension V2TXLivePusherPlugin {
    
    public func flutterImage(at path: String) -> UIImage? {
        guard let path = flutterBundlePath(assetPath: path) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    public func flutterBundlePath(assetPath: String) -> String? {
        guard let imgKey = pluginManager?.registrar.lookupKey(forAsset: assetPath) else {
            return assetPath
        }
        return Bundle.main.path(forResource: imgKey, ofType: nil)
    }
}

// MARK: - V2TXLivePusherObserver回调
extension V2TXLivePusherPlugin: V2TXLivePusherObserver {
    
    ///  错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示。
    public func onError(_ code: V2TXLiveCode, message msg: String, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onError, params: ["errCode": code.rawValue, "errMsg": msg , "extraInfo": extraInfo as Any])
    }
    /// 直播推流器错误通知，推流器出现错误时，会回调该通知
    public func onWarning(_ code: V2TXLiveCode, message msg: String, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onWarning, params: ["errCode": code.rawValue, "errMsg": msg , "extraInfo": extraInfo as Any])
    }
    
    /// 首帧音频采集完成的回调通知
    public func onCaptureFirstAudioFrame() {
        invokeListener(type: .onCaptureFirstAudioFrame)
    }
    
    /// 首帧视频采集完成的回调通知
    public func onCaptureFirstVideoFrame() {
        invokeListener(type: .onCaptureFirstVideoFrame)
    }
    
    /// 麦克风采集音量值回调
    public func onMicrophoneVolumeUpdate(_ volume: Int) {
        invokeListener(type: .onMicrophoneVolumeUpdate, params: ["volume": volume])
    }
    
    /// 推流器连接状态回调通知
    public func onPushStatusUpdate(_ status: V2TXLivePushStatus, message msg: String, extraInfo: [AnyHashable : Any]) {
        invokeListener(type: .onPushStatusUpdate, params: ["status": status.rawValue, "errMsg": msg , "extraInfo": extraInfo as Any])
    }
    
    /// 直播推流器统计数据回调
    public func onStatisticsUpdate(_ statistics: V2TXLivePusherStatistics) {
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
    public func onSnapshotComplete(_ image: UIImage?) {
        guard let imageData = image?.pngData() else {
            return
        }
        let flutterData = FlutterStandardTypedData(bytes: imageData)
        invokeListener(type: .onSnapshotComplete, params: ["image": flutterData])
    }
    
    /// 自定义视频处理回调
    public func onProcessVideoFrame(_ srcFrame: V2TXLiveVideoFrame, dstFrame: V2TXLiveVideoFrame) {
        guard let beautyInstance = beautyInstance else {
            dstFrame.textureId = srcFrame.textureId
            return
        }
        
        let srcBeautyFrame = ConvertBeautyFrame.convertV2VideoFrame(v2VideoFrame: srcFrame)
        let dstBeautyFrame = ConvertBeautyFrame.convertV2VideoFrame(v2VideoFrame: dstFrame)
        let dstThirdFrame = beautyInstance.onProcessVideoFrame(srcFrame: srcBeautyFrame,
                                                               dstFrame: dstBeautyFrame)
        dstFrame.textureId = dstThirdFrame.textureId
        dstFrame.pixelBuffer = dstThirdFrame.pixelBuffer
        if let pixelFormat = dstThirdFrame.pixelFormat {
            dstFrame.pixelFormat = ConvertBeautyFrame.convertToV2LivePixelFormat(beautyPixelFormat: pixelFormat)
        }
        if let bufferType = dstThirdFrame.bufferType {
            dstFrame.bufferType = ConvertBeautyFrame.convertToV2LiveBufferType(beautyBufferType: bufferType)
        }
        dstFrame.width = dstThirdFrame.width
        dstFrame.height = dstThirdFrame.height
        dstFrame.data = dstThirdFrame.data
        dstFrame.rotation = V2TXLiveRotation(rawValue: dstThirdFrame.rotation.rawValue) ?? dstFrame.rotation
    }
    
    /// SDK 内部的 OpenGL 环境的销毁通知
    public func onGLContextDestroyed() {
        if let customBeautyInstance = TXLivePluginManager.getBeautyInstance() {
            customBeautyInstance.destroyCustomBeautyProcesser()
        }
        self.beautyInstance = nil
        invokeListener(type: .onGLContextDestroyed, params: nil)
    }

    public func onScreenCaptureStarted() {
        invokeListener(type: .onScreenCaptureStarted)
    }

    public func onScreenCaptureStopped() {
        invokeListener(type: .onScreenCaptureStopped)
    }
    
    /// 设置云端的混流转码参数的回调，对应于 [setMixTranscodingConfig](@ref V2TXLivePusher#setMixTranscodingConfig:) 接口
    public func onSetMixTranscodingConfig(_ code: V2TXLiveCode, message msg: String) {
        invokeListener(type: .onSetMixTranscodingConfig, params: ["errCode": code.rawValue, "errMsg": msg])
    }
}

// MARK: - Private setFramework
extension V2TXLivePusherPlugin {
    
    private func setFramework() {
        let jsonDic: [String: Any] = ["framework": 23,
                                      "component": 1]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        pusher.setProperty("setFramework", value: (jsonString as NSString))
    }
}

// MARK: - V2TXLivePusherObserver Flutter回调
extension V2TXLivePusherPlugin {
    func invokeListener(type: V2TXLivePusherObserverType, params: Any? = nil) {
        Logger.info(content: "V2TXLivePusherPlugin received observer \(type.rawValue)")
        var arguments: [String: Any] = [:]
        arguments["type"] = type.rawValue
        
        if let paramsValue = params {
            arguments["params"] = paramsValue
        }
        /// 方法名唯一， Type区分使用那个方法
        self.channel.invokeMethod("onPusherListener", arguments: arguments)
    }
}
