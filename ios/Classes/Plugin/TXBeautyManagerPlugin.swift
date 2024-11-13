//
//  TXBeautyManagerPlugin.swift
//  live_flutter_plugin
//
//  Created by jack on 2022/2/25.
//

import Foundation
import TXLiteAVSDK_Professional
import Flutter

// MARK: - Private: TXBeautyManager 调用
extension V2TXLivePusherPlugin {
   
    /// 设置美颜（磨皮）算法
    /// TXBeautyStyleSmooth, TXBeautyStyleNature, TXBeautyStylePitu
    @objc
    func setBeautyStyle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let beautyValue = MethodUtils.getMethodParams(call: call, key: "beautyStyle", resultType: NSNumber.self)?.intValue,
                let beautyStyle = TXBeautyStyle(rawValue: beautyValue)
        else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "beautyStyle", result: result)
            return
        }
        beautyManager.setBeautyStyle(beautyStyle)
        result(NSNumber(value: 0))
    }
    
    /// 设置美颜级别
    @objc
    func setBeautyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let beautyLevel = MethodUtils.getMethodParams(call: call, key: "beautyLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "beautyLevel", result: result)
            return
        }
        beautyManager.setBeautyLevel(beautyLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置美白级别
    @objc
    func setWhitenessLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let whitenessLevel = MethodUtils.getMethodParams(call: call, key: "whitenessLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "whitenessLevel", result: result)
            return
        }
        beautyManager.setWhitenessLevel(whitenessLevel)
        result(NSNumber(value: 0))
    }
    
    /// 开启清晰度增强
    @objc
    func enableSharpnessEnhancement(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "enable", result: result)
            return
        }
        beautyManager.enableSharpnessEnhancement(enable)
        result(NSNumber(value: 0))
    }
    
    /// 设置红润级别
    @objc
    func setRuddyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let ruddyLevel = MethodUtils.getMethodParams(call: call, key: "ruddyLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "ruddyLevel", result: result)
            return
        }
        beautyManager.setRuddyLevel(ruddyLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置指定素材滤镜特效
    /// image 指定素材，即颜色查找表图片。必须使用 png 格式
    @objc
    func setFilter(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let imageUrl = MethodUtils.getMethodParams(call: call, key: "imageUrl", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "imageUrl", result: result)
            return
        }
        guard let type = MethodUtils.getMethodParams(call: call, key: "type", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "type", result: result)
            return
        }
        if type == "network" {
            let queue = DispatchQueue(label: "setFilter")
            queue.async { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) else {
                    return
                }
                guard let image = UIImage(data: data, scale: 1) else {
                    return
                }
                self.beautyManager.setFilter(image)
            }
            result(nil)
        } else if let image = flutterImage(at: imageUrl) {
            beautyManager.setFilter(image)
            result(NSNumber(value: 0))
        } else {
            result(nil)
        }
    }
    
    /// 设置滤镜浓度
    @objc
    func setFilterStrength(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let strength = MethodUtils.getMethodParams(call: call, key: "strength", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "strength", result: result)
            return
        }
        beautyManager.setFilterStrength(strength)
        result(NSNumber(value: 0))
    }
    
    /// 设置大眼级别，该接口仅在 企业版 SDK 中生效
    @objc
    func setEyeScaleLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let eyeScaleLevel = MethodUtils.getMethodParams(call: call, key: "eyeScaleLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "eyeScaleLevel", result: result)
            return
        }
        beautyManager.setEyeScaleLevel(eyeScaleLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置瘦脸级别，该接口仅在 企业版 SDK 中生效
    @objc
    func setFaceSlimLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let faceSlimLevel = MethodUtils.getMethodParams(call: call, key: "faceSlimLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "faceSlimLevel", result: result)
            return
        }
        beautyManager.setFaceSlimLevel(faceSlimLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置 V 脸级别，该接口仅在 企业版 SDK 中生效
    @objc
    func setFaceVLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let faceVLevel = MethodUtils.getMethodParams(call: call, key: "faceVLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "faceVLevel", result: result)
            return
        }
        beautyManager.setFaceVLevel(faceVLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置下巴拉伸或收缩，该接口仅在 企业版 SDK 中生效
    @objc
    func setChinLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let chinLevel = MethodUtils.getMethodParams(call: call, key: "chinLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "chinLevel", result: result)
            return
        }
        beautyManager.setChinLevel(chinLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置短脸级别，该接口仅在 企业版 SDK 中生效
    @objc
    func setFaceShortLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let faceShortLevel = MethodUtils.getMethodParams(call: call, key: "faceShortLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "faceShortLevel", result: result)
            return
        }
        beautyManager.setFaceShortLevel(faceShortLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置瘦鼻级别，该接口仅在 企业版 SDK 中生效
    @objc
    func setNoseSlimLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let noseSlimLevel = MethodUtils.getMethodParams(call: call, key: "noseSlimLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "noseSlimLevel", result: result)
            return
        }
        beautyManager.setNoseSlimLevel(noseSlimLevel)
        result(NSNumber(value: 0))
    }
    
    /// 设置亮眼 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setEyeLightenLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "eyeLightenLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "eyeLightenLevel", result: result)
            return
        }
        beautyManager.setEyeLightenLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置白牙 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setToothWhitenLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "toothWhitenLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "toothWhitenLevel", result: result)
            return
        }
        beautyManager.setToothWhitenLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置祛皱 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setWrinkleRemoveLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "wrinkleRemoveLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "WrinkleRemoveLevel", result: result)
            return
        }
        beautyManager.setWrinkleRemoveLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置祛眼袋 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setPounchRemoveLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "pounchRemoveLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "pounchRemoveLevel", result: result)
            return
        }
        beautyManager.setPounchRemoveLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置法令纹 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setSmileLinesRemoveLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "smileLinesRemoveLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "smileLinesRemoveLevel", result: result)
            return
        }
        beautyManager.setSmileLinesRemoveLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置发际线 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setForeheadLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "foreheadLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "foreheadLevel", result: result)
            return
        }
        beautyManager.setForeheadLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置眼距 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setEyeDistanceLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "eyeDistanceLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "eyeDistanceLevel", result: result)
            return
        }
        beautyManager.setEyeDistanceLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置眼角 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setEyeAngleLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "eyeAngleLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "eyeAngleLevel", result: result)
            return
        }
        beautyManager.setEyeAngleLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置嘴型 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setMouthShapeLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "mouthShapeLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "mouthShapeLevel", result: result)
            return
        }
        beautyManager.setMouthShapeLevel(level)
        result(NSNumber(value: 0))
    }
    
    ///  设置鼻翼 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setNoseWingLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "noseWingLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "noseWingLevel", result: result)
            return
        }
        beautyManager.setNoseWingLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置鼻子位置 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setNosePositionLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "nosePositionLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "nosePositionLevel", result: result)
            return
        }
        beautyManager.setNosePositionLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置嘴唇厚度 ，该接口仅在 企业版 SDK 中生效
    @objc
    func setLipsThicknessLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "lipsThicknessLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "lipsThicknessLevel", result: result)
            return
        }
        beautyManager.setLipsThicknessLevel(level)
        result(NSNumber(value: 0))
    }
    
    /// 设置脸型，该接口仅在 企业版 SDK 中生效
    @objc
    func setFaceBeautyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "faceBeautyLevel", resultType: NSString.self)?.floatValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "faceBeautyLevel", result: result)
            return
        }
        beautyManager.setFaceBeautyLevel(level)
        result(NSNumber(value: 0))
    }
}
