//
//  TXLivePluginDef.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/21.
//

import Foundation

class TXLivePluginDef {
    static let managerChannelName = "live_cloud_manager_channel"
    
    /// 函数调用参数key定义
    enum ParamKey: String {
        /// 创建销毁pusher、player实例对象的参数key
        case callManagerIDKey = "identifier"
    }
}

enum TXLiveFlutterCode: Int {
    case ok = 0
    /// 暂未归类的错误码
    case unknown = -1
    /// 参数未找到
    case paramNotFound = -1_001
    /// 参数类型错误
    case paramTypeError = -1_002
    /// platformView 未找到
    case platformViewNotFound = -1_003
    /// 获取value为空
    case valueIsNull = -1_004
}

enum V2TXLivePlayerObserverType: String {
    /// 直播播放器错误
    case onError
    /// 直播播放器警告
    case onWarning
    /// 直播播放器分辨率变化
    case onVideoResolutionChanged
    /// 已经成功连接到服务器
    case onConnected
    /// 视频播放事件
    case onVideoPlaying
    /// 音频播放事件
    case onAudioPlaying
    /// 视频加载事件
    case onVideoLoading
    /// 音频加载事件
    case onAudioLoading
    /// 播放器音量大小
    case onPlayoutVolumeUpdate
    /// 直播播放器统计数据回调
    case onStatisticsUpdate
    /// 截图回调
    case onSnapshotComplete
    /// 自定义视频渲染回调
    case onRenderVideoFrame
    /// 收到 SEI 消息的回调
    case onReceiveSeiMessage
    /// 画中画状态变更回调
    case onPictureInPictureStateUpdate
}

enum V2TXLivePusherObserverType: String {
    /// 直播推流器错误通知，推流器出现错误时，会回调该通知
    case onError
    /// 直播推流器警告通知
    case onWarning
    /// 首帧音频采集完成的回调通知
    case onCaptureFirstAudioFrame
    /// 首帧视频采集完成的回调通知
    case onCaptureFirstVideoFrame
    /// 麦克风采集音量值回调
    case onMicrophoneVolumeUpdate
    /// 推流器连接状态回调通知
    case onPushStatusUpdate
    /// 直播推流器统计数据回调
    case onStatisticsUpdate
    /// 截图回调
    case onSnapshotComplete
    /// 自定义视频处理回调
    case onProcessVideoFrame
    /// SDK 内部的 OpenGL 环境的销毁通知
    case onGLContextDestroyed
    /// 设置云端的混流转码参数的回调
    case onSetMixTranscodingConfig
    /// 当屏幕分享开始时，SDK 会通过此回调通知
    case onScreenCaptureStarted
    /// 当屏幕分享停止时，SDK 会通过此回调通知
    case onScreenCaptureStopped
    
    /// 音频开始播放
    case onMusicObserverStart
    /// 音频播放中
    case onMusicObserverPlayProgress
    /// 音频播放结束
    case onMusicObserverComplete
}

enum V2TXLivePremierObserverType: String {
  /// 自定义 Log 输出回调接口
  case onLog
  /// setLicence 接口回调
  case onLicenceLoaded
}
