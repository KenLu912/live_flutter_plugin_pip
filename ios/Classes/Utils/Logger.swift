//
//  Logger.swift
//  live_flutter_plugin
//
//  Created by jack on 2022/3/17.
//

import Flutter

class Logger {
    
    static func info(file: String = #file,
                     line: Int = #line,
                     function: String = #function,
                     content: String) {
        txf_log_swift(TXE_LOG_INFO, file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), content.cString(using: .utf8))
    }
    
    static func error(file: String = #file,
                      line: Int = #line,
                      function: String = #function,
                      content: String) {
        txf_log_swift(TXE_LOG_ERROR, file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), content.cString(using: .utf8))
    }
    
    
    static func flutterMethodInfo(_ call: FlutterMethodCall) {
        guard let arguments = call.arguments else {
            Logger.info(content: "flutter method=\(call.method)|arguments: nil")
            return
        }
        if let args = arguments as? Dictionary<String, Any>, args.count > 0 {
            var argsInfo = ""
            for parameter in args.keys {
                if let value = args[parameter] {
                    argsInfo.append("\(parameter):\(value), ")
                }
            }
            Logger.info(content: "flutter method=\(call.method)|arguments: {\(argsInfo)}")
        } else {
            Logger.info(content: "flutter method=\(call.method)|arguments: {\(arguments)}")
        }
    }
    
    static func flutterMethodError(call: FlutterMethodCall, errCode: Int, errMsg: String) {
        guard let arguments = call.arguments else {
            Logger.error(content: "flutter method=\(call.method)|arguments=nil|error={errCode: \(errCode), errMsg: \(errMsg)}")
            return
        }
        if let args = arguments as? Dictionary<String, Any>, args.count > 0 {
            var argsInfo = ""
            for parameter in args.keys {
                if let value = args[parameter] {
                    argsInfo.append("\(parameter):\(value), ")
                }
            }
            Logger.error(content: "flutter method=\(call.method)|arguments={\(argsInfo)}|error={errCode: \(errCode), errMsg: \(errMsg)}")
        } else {
            Logger.error(content: "flutter method=\(call.method)|arguments={\(arguments)}|error={errCode: \(errCode), errMsg: \(errMsg)}")
        }
    }
    
}
