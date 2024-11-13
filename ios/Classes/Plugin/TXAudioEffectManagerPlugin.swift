//
//  TXAudioEffectManagerPlugin.swift
//  live_flutter_plugin
//
//  Created by jack on 2022/2/25.
//

import Foundation
import TXLiteAVSDK_Professional
import Flutter

// MARK: - Private: TXAudioEffectManager 调用
extension V2TXLivePusherPlugin {
    
    /// 开始播放背景音乐
    @objc
    func startPlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let musicParamString = MethodUtils.getMethodParams(call: call, key: "musicParam", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "musicParam", result: result)
            return
        }
        let musicParam = JsonUtil.getDictionaryFromJSONString(jsonString: musicParamString)
        let param = TXAudioMusicParam()
        
        param.id = (musicParam["id"] as? Int32) ?? 0
        param.path = (musicParam["path"] as? String) ?? ""
        if let loopCount = musicParam["loopCount"] as? Int {
            param.loopCount = loopCount
        }
        if let publish = musicParam["publish"] as? Bool {
            param.publish = publish
        }
        if let isShortFile = musicParam["isShortFile"] as? Bool {
            param.isShortFile = isShortFile
        }
        if let startTimeMS = musicParam["startTimeMS"] as? Int {
            param.startTimeMS = startTimeMS
        }
        if let endTimeMS = musicParam["endTimeMS"] as? Int {
            param.endTimeMS = endTimeMS
        }
        audioEffectManager.startPlayMusic(param) { [weak self] (errCode) in
            guard let self = self else { return }
            self.invokeListener(type: .onMusicObserverStart, params: ["id": param.id, "errCode": errCode])
        } onProgress: { [weak self] (progressMs, durationMs) in
            guard let self = self else { return }
            self.invokeListener(type: .onMusicObserverPlayProgress, params: ["id": param.id, "progressMs": progressMs, "durationMs": durationMs])
        } onComplete: { [weak self] (errCode) in
            guard let self = self else { return }
            self.invokeListener(type: .onMusicObserverComplete, params: ["id": param.id, "errCode": errCode])
        }
        result(NSNumber(value: 0))
    }
    
    /// 开启耳返
    @objc
    func enableVoiceEarMonitor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType: NSNumber.self)?.boolValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "enable", result: result)
            return
        }
        audioEffectManager.enableVoiceEarMonitor(enable)
        result(NSNumber(value: 0))
    }
    
    /// 设置耳返音量
    @objc
    func setVoiceEarMonitorVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let volume = MethodUtils.getMethodParams(call: call, key: "volume", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "volume", result: result)
            return
        }
        audioEffectManager.setVoiceEarMonitorVolume(volume)
        result(NSNumber(value: 0))
    }
    
    /// 设置人声的混响效果（KTV、小房间、大会堂、低沉、洪亮...）
    @objc
    func setVoiceReverbType(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let type = MethodUtils.getMethodParams(call: call, key: "type", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "type", result: result)
            return
        }
        guard let voiceReverbType = TXVoiceReverbType(rawValue: type) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: "type", result: result)
            return
        }
        audioEffectManager.setVoiceReverbType(voiceReverbType)
        result(NSNumber(value: 0))
    }
    
    /// 设置人声的变声特效（萝莉、大叔、重金属、外国人...）
    @objc
    func setVoiceChangerType(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let type = MethodUtils.getMethodParams(call: call, key: "type", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "type", result: result)
            return
        }
        guard let voiceChangerType = TXVoiceChangeType(rawValue: type) else {
            FlutterResultUtils.handleMethod(code: .paramTypeError, methodName: call.method, paramKey: "type", result: result)
            return
        }
        audioEffectManager.setVoiceChangerType(voiceChangerType)
        result(NSNumber(value: 0))
    }
    
    /// 设置麦克风采集人声的音量
    @objc
    func setVoiceCaptureVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let volume = MethodUtils.getMethodParams(call: call, key: "volume", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "volume", result: result)
            return
        }
        audioEffectManager.setVoiceVolume(volume)
        result(NSNumber(value: 0))
    }
    
    /// 停止播放背景音乐
    @objc
    func stopPlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        audioEffectManager.stopPlayMusic(id)
        result(NSNumber(value: 0))
    }
    
    /// 暂停播放背景音乐
    @objc
    func pausePlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        audioEffectManager.pausePlayMusic(id)
        result(NSNumber(value: 0))
    }
    
    /// 恢复播放背景音乐
    @objc
    func resumePlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        audioEffectManager.resumePlayMusic(id)
        result(NSNumber(value: 0))
    }
    
    /// 设置背景音乐的远端音量大小，即主播可以通过此接口设置远端观众能听到的背景音乐的音量大小。
    @objc
    func setMusicPublishVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        guard let volume = MethodUtils.getMethodParams(call: call, key: "volume", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "volume", result: result)
            return
        }
        audioEffectManager.setMusicPublishVolume(id, volume: volume)
        result(NSNumber(value: 0))
    }
    
    /// 设置背景音乐的本地音量大小，即主播可以通过此接口设置主播自己本地的背景音乐的音量大小。
    ///  volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
    @objc
    func setMusicPlayoutVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        guard let volume = MethodUtils.getMethodParams(call: call, key: "volume", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "volume", result: result)
            return
        }
        audioEffectManager.setMusicPlayoutVolume(id, volume: volume)
        result(NSNumber(value: 0))
    }
    
    /// 设置全局背景音乐的本地和远端音量的大小
    @objc
    func setAllMusicVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let volume = MethodUtils.getMethodParams(call: call, key: "volume", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "volume", result: result)
            return
        }
        audioEffectManager.setAllMusicVolume(volume)
        result(NSNumber(value: 0))
    }
    
    /// 调整背景音乐的音调高低
    /// pitch    音调，默认值是0.0f，范围是：[-1 ~ 1] 之间的浮点数
    @objc
    func setMusicPitch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        guard let pitch = MethodUtils.getMethodParams(call: call, key: "pitch", resultType: NSString.self)?.doubleValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "pitch", result: result)
            return
        }
        audioEffectManager.setMusicPitch(id, pitch: pitch)
        result(NSNumber(value: 0))
    }
    
    /// 调整背景音乐的变速效果
    /// speedRate    速度，默认值是1.0f，范围是：[0.5 ~ 2] 之间的浮点数
    @objc
    func setMusicSpeedRate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        guard let speedRate = MethodUtils.getMethodParams(call: call, key: "speedRate", resultType: NSString.self)?.doubleValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "speedRate", result: result)
            return
        }
        audioEffectManager.setMusicSpeedRate(id, speedRate: speedRate)
        result(NSNumber(value: 0))
    }
    
    /// 获取背景音乐当前的播放进度（单位：毫秒）
    @objc
    func getMusicCurrentPosInMS(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        let ms = audioEffectManager.getMusicCurrentPos(inMS: id)
        result(NSNumber(value: ms))
    }
    
    /// 设置背景音乐的播放进度（单位：毫秒）
    @objc
    func seekMusicToPosInMS(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = MethodUtils.getMethodParams(call: call, key: "id", resultType: NSNumber.self)?.int32Value else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "id", result: result)
            return
        }
        guard let pts = MethodUtils.getMethodParams(call: call, key: "pts", resultType: NSNumber.self)?.intValue else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "pts", result: result)
            return
        }
        audioEffectManager.seekMusicToPos(inMS: id, pts: pts)
        result(NSNumber(value: 0))
    }
    
    /// 获取景音乐文件的总时长（单位：毫秒）
    @objc
    func getMusicDurationInMS(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let path = MethodUtils.getMethodParams(call: call, key: "path", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: call.method, paramKey: "path", result: result)
            return
        }
        let res = audioEffectManager.getMusicDuration(inMS: path)
        result(NSNumber(value: res))
    }
    
}
