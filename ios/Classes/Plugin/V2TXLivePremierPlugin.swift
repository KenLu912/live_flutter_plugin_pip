//
//  V2TXLivePremier.swift
//  live_flutter_plugin
//
//  Created by jack on 2022/3/2.
//

import Foundation
import TXLiteAVSDK_Professional
import Flutter

class V2TXLivePremierPlugin: NSObject {
    private let channel: FlutterMethodChannel
    weak var pluginManager: TXLivePluginManager?
    
    /// 保留一个标记位用于控制新建的TXLivePlayer是否打开PIP模式
    var enablePIPMode: Bool = false
    
    init(pluginManager: TXLivePluginManager) {
        self.pluginManager = pluginManager
        self.channel = FlutterMethodChannel(name: "live_cloud_premier", binaryMessenger: pluginManager.messenger)
        
        super.init()
        
        self.channel.setMethodCallHandler(handle)
        V2TXLivePremier.setObserver(self)
    }
    
    deinit {
        self.channel.setMethodCallHandler(nil)
    }
}

// MARK: - Flutter 消息回调
extension V2TXLivePremierPlugin {
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Logger.flutterMethodInfo(call)
        
        let selectorName = "\(call.method)WithCall:result:"
        let selector = NSSelectorFromString(selectorName)
        
        guard self.responds(to: selector) else {
            Logger.error(content: "V2TXLivePremierPlugin \(call.method) FlutterMethodNotImplemented")
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

// MARK: - Flutter Channel Method
extension V2TXLivePremierPlugin {
    
    @objc
    func setLicence(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let url = MethodUtils.getMethodParams(call: call, key: "url", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "url", result: result)
            return
        }
        
        guard let key = MethodUtils.getMethodParams(call: call, key: "key", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "key", result: result)
            return
        }
        
        V2TXLivePremier.setLicence(url, key: key)
        
        result(nil)
    }
    
    /// 获取SDKVersion
    @objc
    func getSDKVersionStr(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let version = V2TXLivePremier.getSDKVersionStr()
        result(version)
    }
    
    /// 设置 Log 的配置信息
    @objc
    func setLogConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let configInfo = MethodUtils.getMethodParams(call: call, key: "config", resultType: [String: Any].self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "config", result: result)
            return
        }
        
        let config = v2TXLiveLogConfig(from: configInfo)
        let code = V2TXLivePremier.setLogConfig(config)
        
        result(code.rawValue)
    }
    
    
    /// 设置 SDK 接入环境
    ///
    /// @note 如您的应用无特殊需求，请不要调用此接口进行设置。
    /// @param env 目前支持 “default” 和 “GDPR” 两个参数
    ///        - default：默认环境，SDK 会在全球寻找最佳接入点进行接入。
    ///        - GDPR：所有音视频数据和质量统计数据都不会经过中国大陆地区的服务器。
    @objc
    func setEnvironment(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let env = MethodUtils.getMethodParams(call: call, key: "env", resultType: NSString.self)?.utf8String else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "env", result: result)
            return
        }
        
        let code = V2TXLivePremier.setEnvironment(env)
        
        result(code.rawValue)
    }
    
    
    /// 设置 SDK sock5 代理配置
    ///
    /// @param host sock5 代理服务器的地址
    /// @param port sock5 代理服务器的端口
    /// @param username sock5 代理服务器的验证的用户名
    /// @param password sock5 代理服务器的验证的密码
    /// @param config   sock5 代理服务器的协议配置
    ///
    @objc
    func setSocks5Proxy(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let host = MethodUtils.getMethodParams(call: call, key: "host", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "host", result: result)
            return
        }
        
        guard let port = MethodUtils.getMethodParams(call: call, key: "port", resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "port", result: result)
            return
        }
        
        guard let username = MethodUtils.getMethodParams(call: call, key: "username", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "username", result: result)
            return
        }
        
        guard let password = MethodUtils.getMethodParams(call: call, key: "password", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "password", result: result)
            return
        }
        
        guard let configInfo = MethodUtils.getMethodParams(call: call, key: "config", resultType: [String: Any].self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "config", result: result)
            return
        }
        
        let config = v2TXLiveSocks5ProxyConfig(from: configInfo)
        let code = V2TXLivePremier.setSocks5Proxy(host, port: port, username: username, password: password, config: config)
        
        result(code.rawValue)
    }

    /// 设置 userId
    ///
    /// @param userId 业务侧自身维护的用户/设备id。
    @objc
    func setUserId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "userId", result: result)
            return
        }
        
        V2TXLivePremier.setUserId(userId)
        
        result(nil)
    }
    
    /// 开关PIP模式
    ///
    /// @param  enable  0为关闭，其它数字表示打开
    @objc
    func enablePictureInPictureMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType:Bool.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "enable", result: result)
            return
        }
        
        enablePIPMode = enable
        
        result(NSNumber(value: V2TXLiveCode.TXLIVE_OK.rawValue))
    }
}

// MARK: - V2TXLivePremierObserver
extension V2TXLivePremierPlugin: V2TXLivePremierObserver {
    
    func onLog(_ level: V2TXLiveLogLevel, log: String) {
        invokeListener(type: .onLog, params: ["level": level.rawValue, "log": log])
    }
    
    func onLicenceLoaded(_ result: Int32, reason: String) {
        Logger.info(content: "V2TXLivePremierPlugin received onLicenceLoaded result:\(result) reason:\(reason)")
        invokeListener(type: .onLicenceLoaded, params: ["result": result, "reason": reason])
    }
}

// MARK: - Flutter Channel回调
extension V2TXLivePremierPlugin {
    func invokeListener(type: V2TXLivePremierObserverType, params: Any? = nil) {
        var arguments: [String: Any] = [:]
        arguments["type"] = type.rawValue
        
        if let paramsValue = params {
            arguments["params"] = paramsValue
        }
        /// 方法名唯一， Type区分使用那个方法
        self.channel.invokeMethod("onPremierListener", arguments: arguments)
    }
}

// MARK: - Private
extension V2TXLivePremierPlugin {
    
    private func v2TXLiveLogConfig(from configInfo: [String:Any]) -> V2TXLiveLogConfig {
        let config = V2TXLiveLogConfig()
        if let value = configInfo["logLevel"] as? Int,
           let logLevel = V2TXLiveLogLevel(rawValue: value) {
            config.logLevel = logLevel
        }
        if let enableObserver = configInfo["enableObserver"] as? NSNumber {
            config.enableObserver = enableObserver.boolValue
        }
        if let enableConsole = configInfo["enableConsole"] as? NSNumber {
            config.enableConsole = enableConsole.boolValue
        }
        if let enableLogFile = configInfo["enableLogFile"] as? NSNumber {
            config.enableLogFile = enableLogFile.boolValue
        }
        if let logPath = configInfo["logPath"] as? String {
            config.logPath = logPath
        }
        return config
    }

    private func v2TXLiveSocks5ProxyConfig(from configInfo: [String:Any]) -> V2TXLiveSocks5ProxyConfig {
        let config = V2TXLiveSocks5ProxyConfig()
        if let supportHttps = configInfo["supportHttps"] as? NSNumber {
            config.supportHttps = supportHttps.boolValue
        }
        if let supportTcp = configInfo["supportTcp"] as? NSNumber {
             config.supportTcp = supportTcp.boolValue
        }
        if let supportUdp = configInfo["supportUdp"] as? NSNumber {
            config.supportUdp = supportUdp.boolValue
        }
        return config
    }
    
}
