//
//  V2TXLivePusherPlugin.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/20.
//


import Flutter
import UIKit
import TXLiteAVSDK_Professional
import TXCustomBeautyProcesserPlugin

/// Native管理pusher和player的单例类
/// 负责对Dart对象创建的Pusher和Player实例一一对应
public class TXLivePluginManager: NSObject {
    static let channelName = "live_cloud_manager_channel"
    private static var customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory? = nil
    private static let beautyQueue = DispatchQueue(label: "live_beauty_queue")
    
    /// Pusher 实例管理对象
    private var pusherMap: [String: V2TXLivePusherPlugin] = [:]
    /// Player 实例管理兑现
    private var playerMap: [String: V2TXLivePlayerPlugin] = [:]
    
    private var premier: V2TXLivePremierPlugin? = nil
    
    private let channel: FlutterMethodChannel
    
    let registrar: FlutterPluginRegistrar
    let viewFactory: V2LiveRenderViewFactory
    
    var messenger: FlutterBinaryMessenger {
        return registrar.messenger()
    }
    
    /// LiveManager管理对象初始化
    /// - Parameter registrar: Flutter消息绑定器
    init(registrar: FlutterPluginRegistrar, viewFactory: V2LiveRenderViewFactory) {
        self.channel = FlutterMethodChannel(name: TXLivePluginManager.channelName, binaryMessenger: registrar.messenger())
        self.registrar = registrar
        self.viewFactory = viewFactory
        super.init()
    }
    
    /// 对应Method函数
    enum Method: String {
        case createNativePusher
        case createNativePlayer
        case destroyNativePusher
        case destroyNativePlayer
        case enablePictureInPictureMode
    }
}

/// MARK: - private func
extension TXLivePluginManager {
    private func createV2TXLivePusherPlugin(identifier: String, mode: V2TXLiveMode = .RTC) -> V2TXLivePusherPlugin {
        let pusher = V2TXLivePusherPlugin(identifier: identifier,
                                               mode: mode,
                                               pluginManager: self)
        pusherMap[identifier] = pusher
        return pusher
    }
    
    private func destroyV2TXLivePusherPlugin(identifier: String) {
        guard let pusher = pusherMap.removeValue(forKey: identifier) else {
            return
        }
        pusher.destroy()
    }
    
    private func createV2TXLivePlayerPlugin(identifier: String) -> V2TXLivePlayerPlugin {
        let player = V2TXLivePlayerPlugin(identifier: identifier, pluginManager: self)
        playerMap[identifier] = player
        
        // 创建Player后，设置其PIP模式
        enablePictureInPictureMode(premier?.enablePIPMode ?? false, forPlayer: player)
        
        return player
    }
    
    private func destroyV2TXLivePlayerPlugin(identifier: String) {
        guard let player = playerMap.removeValue(forKey: identifier) else {
            return
        }
        
        player.destroy()
    }
    
    /// 设置指定标识符播放器的PIP模式
    ///
    /// @param enable true 表示打开，否则关闭
    /// @param identifier 播放器标识
    ///
    /// @return 搜索到对应的播放器则返回true，否则返回false
    @discardableResult
    private func enablePictureInPictureMode(_ enable: Bool, forID identifier: String) -> Bool {
        guard let player = playerMap[identifier] else {
            return false
        }
        
        enablePictureInPictureMode(enable, forPlayer: player)
        return true
    }
    
    /// 设置指定播放器的PIP模式
    ///
    /// @param enable true 表示打开，否则关闭
    /// @param player 播放器
    private func enablePictureInPictureMode(_ enable: Bool, forPlayer player: V2TXLivePlayerPlugin) {
        // Do the trick to manipulate player's core private player property by building a fake call
        let call = FlutterMethodCall(methodName: "enablePIPMode", arguments: ["enable": enable ? 1 : 0])
        player.enablePictureInPicture(call: call, result: nil)
    }
}

/// MARK: - FlutterPlugin
extension TXLivePluginManager: FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let viewFactory = V2LiveRenderViewFactory(messenger: registrar.messenger())
        let instance = TXLivePluginManager(registrar: registrar, viewFactory: viewFactory)
        instance.premier = V2TXLivePremierPlugin(pluginManager: instance)
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
        registrar.register(viewFactory, withId: V2LiveRenderViewFactory.SIGN)
    }
    
    @objc public static func register(customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory) {
        let updateBeautyWorkItem = DispatchWorkItem {
            self.customBeautyProcesserFactory = customBeautyProcesserFactory
        }
        beautyQueue.sync(execute: updateBeautyWorkItem)
    }
    
    @objc public static func getBeautyInstance() -> ITXCustomBeautyProcesserFactory? {
        var customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory? = nil
        let getBeautyWorkItem = DispatchWorkItem {
            customBeautyProcesserFactory = self.customBeautyProcesserFactory
        }
        beautyQueue.sync(execute: getBeautyWorkItem)
        return customBeautyProcesserFactory
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Logger.flutterMethodInfo(call)
        let key = TXLivePluginDef.ParamKey.callManagerIDKey.rawValue
        guard let identifier: String = MethodUtils.getMethodParams(call: call,
                                                                   key: key,
                                                                   resultType: String.self) else {
            handleFlutterResult(code: .paramNotFound, msg: "Can not find param by key: \(key)", result: result)
            return
        }
        let method = Method(rawValue: call.method)
        switch method {
        case .createNativePusher:
            // 添加pusher
            if let mode = MethodUtils.getMethodParams(call: call, key: "mode", resultType: NSNumber.self)?.uintValue,
                let liveMode = V2TXLiveMode(rawValue: mode) {
                let pusher = createV2TXLivePusherPlugin(identifier: identifier, mode: liveMode)
                pusherMap[identifier] = pusher
            } else {
                let pusher = createV2TXLivePusherPlugin(identifier: identifier)
                pusherMap[identifier] = pusher
            }
        case .destroyNativePusher:
            // 移除pusher
            destroyV2TXLivePusherPlugin(identifier: identifier)
        case .createNativePlayer:
            // 添加player
            let player = createV2TXLivePlayerPlugin(identifier: identifier)
            playerMap[identifier] = player
        case .destroyNativePlayer:
            // 移除player
            destroyV2TXLivePlayerPlugin(identifier: identifier)
            
        default:
            Logger.error(content: "TXLivePluginManager \(call.method) FlutterMethodNotImplemented")
            break
        }
        result(NSNumber(value: 0))
    }
}

// MARK: - Flutter error 处理
extension TXLivePluginManager {
    
    private func handleFlutterResult(code: TXLiveFlutterCode = .unknown, msg: String = "", details: Any? = nil, result: FlutterResult? = nil) {
        let error = FlutterError(code: "\(code.rawValue)", message: msg, details: details)
        result?(error)
    }
}
