package com.tencent.live;

public class TXLivePluginDef {

    public interface ParamKey {
        String CALL_MANAGER_ID_KEY = "identifier";
    }

    public interface ErrorCode {
        int CODE_OK = 0;
        /// 暂未归类的错误码
        int CODE_UNKNOWN = -1;
        /// 参数未找到
        int CODE_PARAMNOTFOUND = -1_001;
        /// 参数类型错误
        int CODE_PARAMTYPEERROR = -1_002;
        /// CODE_PLATFORMVIEW 未找到
        int CODE_PLATFORMVIEWNOTFOUND = -1_003;
        /// 获取value为空
        int CODE_VALUEISNULL = -1_004;
    }

    public enum V2TXLivePlayerObserverType {
        /// 直播播放器错误
        onError("onError"),
        /// 直播播放器警告
        onWarning("onWarning"),
        /// 直播播放器分辨率变化
        onVideoResolutionChanged("onVideoResolutionChanged"),
        /// 已经成功连接到服务器
        onConnected("onConnected"),
        /// 视频播放事件
        onVideoPlaying("onVideoPlaying"),
        /// 音频播放事件
        onAudioPlaying("onAudioPlaying"),
        /// 视频加载事件
        onVideoLoading("onVideoLoading"),
        /// 音频加载事件
        onAudioLoading("onAudioLoading"),
        /// 播放器音量大小
        onPlayoutVolumeUpdate("onPlayoutVolumeUpdate"),
        /// 直播播放器统计数据回调
        onStatisticsUpdate("onStatisticsUpdate"),
        /// 截图回调
        onSnapshotComplete("onSnapshotComplete"),
        /// 自定义视频渲染回调
        onRenderVideoFrame("onRenderVideoFrame"),
        /// 收到 SEI 消息的回调
        onReceiveSeiMessage("onReceiveSeiMessage");

        V2TXLivePlayerObserverType(String name) {
            this.name = name;
        }

        private String name;

        public String getName() {
            return this.name;
        }

        public static V2TXLivePlayerObserverType getByName(String name) {
            for (V2TXLivePlayerObserverType c : V2TXLivePlayerObserverType.values()) {
                if (c.name.equals(name)) {
                    return c;
                }
            }
            return null;
        }

    }

    public enum V2TXLivePusherObserverType {
        /// 直播推流器错误通知，推流器出现错误时，会回调该通知
        onError("onError"),
        /// 直播推流器警告通知
        onWarning("onWarning"),
        /// 首帧音频采集完成的回调通知
        onCaptureFirstAudioFrame("onCaptureFirstAudioFrame"),
        /// 首帧视频采集完成的回调通知
        onCaptureFirstVideoFrame("onCaptureFirstVideoFrame"),
        /// 麦克风采集音量值回调
        onMicrophoneVolumeUpdate("onMicrophoneVolumeUpdate"),
        /// 推流器连接状态回调通知
        onPushStatusUpdate("onPushStatusUpdate"),
        /// 直播推流器统计数据回调
        onStatisticsUpdate("onStatisticsUpdate"),
        /// 截图回调
        onSnapshotComplete("onSnapshotComplete"),
        /// SDK 内部的 OpenGL 环境的创建通知
        onGLContextCreated("onGLContextCreated"),
        /// 自定义视频处理回调
        onProcessVideoFrame("onProcessVideoFrame"),
        /// SDK 内部的 OpenGL 环境的销毁通知
        onGLContextDestroyed("onGLContextDestroyed"),
        /// 设置云端的混流转码参数的回调
        onSetMixTranscodingConfig("onSetMixTranscodingConfig"),
        /// 当屏幕分享开始时，SDK 会通过此回调通知
        onScreenCaptureStarted("onScreenCaptureStarted"),
        /// 当屏幕分享停止时，SDK 会通过此回调通知
        onScreenCaptureStopped("onScreenCaptureStopped"),

        onMusicObserverStart("onMusicObserverStart"),

        onMusicObserverPlayProgress("onMusicObserverPlayProgress"),
        
        onMusicObserverComplete("onMusicObserverComplete");

        V2TXLivePusherObserverType(String name) {
            this.name = name;
        }

        private String name;

        public String getName() {
            return this.name;
        }

        public static V2TXLivePusherObserverType getByName(String name) {
            for (V2TXLivePusherObserverType c : V2TXLivePusherObserverType.values()) {
                if (c.name.equals(name)) {
                    return c;
                }
            }
            return null;
        }

    }

    public enum  V2TXLivePremierObserverType {
        /// 自定义 Log 输出回调接口
        onLog("onLog"),
        /// setLicence 接口回调
        onLicenceLoaded("onLicenceLoaded");

        V2TXLivePremierObserverType(String name) {
            this.name = name;
        }

        private String name;

        public String getName() {
            return this.name;
        }

        public static V2TXLivePremierObserverType getByName(String name) {
            for (V2TXLivePremierObserverType c : V2TXLivePremierObserverType.values()) {
                if (c.name.equals(name)) {
                    return c;
                }
            }
            return null;
        }
    }

}


