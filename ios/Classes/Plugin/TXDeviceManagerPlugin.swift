//
//  TXDeviceManagerPlugin.swift
//  live_flutter_plugin
//
//  Created by jack on 2022/2/25.
//

import Foundation
import TXLiteAVSDK_Professional
import Flutter

// MARK: - Private: TXDeviceManager 调用
extension V2TXLivePusherPlugin {
    
    @objc
    func isFrontCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isFrontCamera = deviceManager.isFrontCamera()
        result(NSNumber(value: isFrontCamera))
    }
    
    @objc
    func switchCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let isFrontCamera = MethodUtils.getMethodParams(call: call, key: "isFrontCamera", resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "isFrontCamera", result: result)
            return
        }
        let code = deviceManager.switchCamera(isFrontCamera)
        result(NSNumber(value: code))
    }
    
    @objc
    func getCameraZoomMaxRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ratio = deviceManager.getCameraZoomMaxRatio()
        result(NSNumber(value: ratio))
    }
    
    @objc
    func setCameraZoomRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let ratio = MethodUtils.getMethodParams(call: call, key: "value", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "ratio", result: result)
            return
        }
        let code = deviceManager.setCameraZoomRatio(CGFloat(ratio))
        result(NSNumber(value: code))
    }

    @objc
    func enableCameraAutoFocus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "enable", result: result)
            return
        }
        let code = deviceManager.enableCameraAutoFocus(enable)
        result(NSNumber(value: code))
    }
    
    @objc
    func isAutoFocusEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = deviceManager.isAutoFocusEnabled()
        result(NSNumber(value: enable))
    }
    
    @objc
    func setCameraFocusPosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let x = MethodUtils.getMethodParams(call: call, key: "x", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "x", result: result)
            return
        }
        guard let y = MethodUtils.getMethodParams(call: call, key: "y", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "y", result: result)
            return
        }
        let code = deviceManager.setCameraFocusPosition(CGPoint(x: x, y: y))
        result(NSNumber(value: code))
    }
    
    
    @objc
    func enableCameraTorch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "enable", result: result)
            return
        }
        let code = deviceManager.enableCameraTorch(enable)
        result(NSNumber(value: code))
    }
    
    @objc
    func setSystemVolumeType(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let typeValue = MethodUtils.getMethodParams(call: call, key: "type", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "type", result: result)
            return
        }
        guard let type = TXSystemVolumeType(rawValue: typeValue) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: "type", result: result)
            return
        }
        let code = deviceManager.setSystemVolumeType(type)
        result(NSNumber(value: code))
    }
    
    @objc
    func setAudioRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let route = MethodUtils.getMethodParams(call: call, key: "route", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "route", result: result)
            return
        }
        guard let routeType = TXAudioRoute(rawValue: route) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: "route", result: result)
            return
        }
        let code = deviceManager.setAudioRoute(routeType)
        result(NSNumber(value: code))
    }
    
}

// MARK: - DeviceManager Mac接口处理
// TODO: - Mac接口调用
extension V2TXLivePusherPlugin {
    
    @objc
    func getDevicesList(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func setCurrentDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func getCurrentDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func setCurrentDeviceVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func getCurrentDeviceVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func setCurrentDeviceMute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    @objc
    func getCurrentDeviceMute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func startMicDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func stopMicDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    @objc
    func startSpeakerDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
}
