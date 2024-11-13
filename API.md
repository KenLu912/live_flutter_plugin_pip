## V2TXLivePlayer

**功能**

腾讯云直播播放器。

主要负责从指定的直播流地址拉取音视频数据，并进行解码和本地渲染播放。

**介绍**

播放器包含如下能力：

- 支持 RTMP、HTTP-FLV、TRTC、WebRTC 协议。
- 屏幕截图，可以截取当前直播流的视频画面。
- 延时调节，可以设置播放器缓存自动调整的最小和最大时间。
- 自定义的视频数据处理，您可以根据项目需要处理直播流中的视频数据后，再进行渲染以及播放。

### SDK 基础函数

| API                                                                                                                                                 | Description         |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [create](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/create.html)                                   | 创建实例                |
| [destroy](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/destroy.html)                                 | 销毁实例                |
| [addListener](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/addListener.html)                         | 添加播放器回调             |
| [removeListener](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/removeListener.html)                   | 移除播放器回调             |

### 播放基础接口

| API                                                                                                                                                 | Description         |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [setRenderViewID](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/setRenderViewID.html)                 | 设置渲染视图的ID           |
| [startLivePlay](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/startLivePlay.html)                     | 开始播放音视频流           |
| [stopPlay](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/stopPlay.html)                               | 停止播放音视频流        |
| [isPlaying](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/isPlaying.html)                             | 播放器是否正在播放中          |

### 视频相关接口

| API                                                                                                                                                 | Description         |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [setRenderRotation](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/setRenderRotation.html)             | 设置本地渲染画面旋转角度        |
| [setRenderFillMode](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/setRenderFillMode.html)             | 设置画面的填充模式 |
| [pauseVideo](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/pauseVideo.html)                           | 暂停播放器的视频流           |
| [resumeVideo](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/resumeVideo.html)                         | 恢复播放器的视频流           |
| [snapshot](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/snapshot.html)                               | 截取播放过程中的视频画面        |
| [enableObserveVideoFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/enableObserveVideoFrame.html) | 开启/关闭对视频帧的监听回调      |

### 音频相关接口

| API                                                                                                                                                 | Description         |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [pauseAudio](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/pauseAudio.html)                           | 暂停播放器的音频流           |
| [resumeAudio](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/resumeAudio.html)                         | 恢复播放器的音频流           |
| [setPlayoutVolume](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/setPlayoutVolume.html)               | 设置播放器音量             |
| [enableVolumeEvaluation](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/enableVolumeEvaluation.html)   | 启用播放音量大小提示          |

### 更多实用接口

| API                                                                                                                                                 | Description         |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [setCacheParams](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/setCacheParams.html)                   | 设置播放器缓存自动调整的最小和最大时间 ( 单位：秒 ) |
| [showDebugView](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/showDebugView.html)                     | 显示仪表盘               |
| [enableReceiveSeiMessage](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/enableReceiveSeiMessage.html) | 开启接收 SEI 消息         |
| [setProperty](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/V2TXLivePlayer/setProperty.html)                         | 调用 V2TXLivePlayer 的高级 API 接口 |


## V2TXLivePlayerObserver

**功能**

腾讯云直播的播放器回调通知。

**介绍**

可以接收 [V2TXLivePlayer](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player/v2_tx_live_player-library.html) 播放器的一些回调通知，包括播放器状态、播放音量回调、音视频首帧回调、统计数据、警告和错误信息等。

### SDK 基础回调

| API                                                                                                                                              | Description         |
|--------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onError](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onError)         | 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示 |
| [onWarning](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onWarning)     | 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败 |
| [onConnected](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onConnected) | 已经成功连接到服务器 |


### 视频相关回调

| API                                                                                                                                                                        | Description         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onVideoPlaying](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onVideoPlaying)                     | 视频播放事件 |
| [onVideoLoading](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onVideoLoading)                     | 视频加载事件 |
| [onSnapshotComplete](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onSnapshotComplete)             | 截图回调 |
| [onVideoResolutionChanged](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onVideoResolutionChanged) | 直播播放器分辨率变化通知 |
| [onRenderVideoFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onRenderVideoFrame)             | 自定义视频渲染回调 |

### 音频相关回调

| API                                                                                                                                                                  | Description |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [onAudioPlaying](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onAudioPlaying)               | 音频播放事件  |
| [onAudioLoading](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onAudioLoading)               | 音频加载事件  |
| [onPlayoutVolumeUpdate](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onPlayoutVolumeUpdate) | 播放器音量大小 |


### 统计回调

| API                                                                                                                                                              | Description         |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onStatisticsUpdate](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onStatisticsUpdate)   | 直播播放器统计数据回调 |

### SEI 回调

| API                                                                                                                                                                | Description         |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onReceiveSeiMessage](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_player_observer/V2TXLivePlayerListenerType.html#onReceiveSeiMessage)   | 收到 SEI 消息的回调 |


## V2TXLivePusher

**功能**

腾讯云直播推流器。

**介绍**

主要负责将本地的音频和视频画面进行编码，并推送到指定的推流地址，支持任意的推流服务端。

推流器包含如下能力：

- 自定义的视频采集，让您可以根据项目需要定制自己的音视频数据源。
- 美颜、滤镜、贴纸，包含多套美颜磨皮算法（自然&光滑）和多款色彩空间滤镜（支持自定义滤镜）。
- Qos 流量控制技术，具备上行网络自适应能力，可以根据主播端网络的具体情况实时调节音视频数据量。
- 脸形调整、动效挂件，支持基于优图 AI 人脸识别技术的大眼、瘦脸、隆鼻等脸形微调以及动效挂件效果，只需要购买优图 License 就可以轻松实现丰富的直播效果。


### SDK 基础函数

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [create](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/create.html)                                     | 创建实例                         |
| [destroy](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/destroy.html)                                   | 销毁实例                         |
| [addListener](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/addListener.html)                           | 添加推流器回调                      |
| [removeListener](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/removeListener.html)                     | 移除推流器回调                      |

### 推流基础接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [setRenderViewID](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setRenderViewID.html)                   | 设置本地摄像头预览视图的ID              |
| [startPush](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/startPush.html)                               | 开始音视频数据推流           |
| [stopPush](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/stopPush.html)                                 | 停止推送音视频数据           |
| [isPushing](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/isPushing.html)                               | 当前推流器是否正在推流中                  |

### 视频相关接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [enableCustomVideoCapture](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/enableCustomVideoCapture.html) | 开启/关闭自定义视频采集              |
| [enableCustomVideoProcess](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/enableCustomVideoProcess.html) | 开启/关闭自定义视频处理              |
| [pauseVideo](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/pauseVideo.html)                             | 暂停推流器的视频流                    |
| [resumeVideo](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/resumeVideo.html)                           | 恢复推流器的视频流                    |
| [sendCustomVideoFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/sendCustomVideoFrame.html)         | 在自定义视频采集模式下，将采集的视频数据发送到SDK |
| [setVideoQuality](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setVideoQuality.html)                   | 设置推流视频编码参数                  |
| [setRenderRotation](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setRenderRotation.html)               | 设置本地摄像头预览画面的旋转角度                 |
| [setRenderMirror](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setRenderMirror.html)                   | 设置摄像头镜像类型 |
| [setEncoderMirror](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setEncoderMirror.html)                 | 设置视频编码镜像 |
| [setWatermark](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setWatermark.html)                         | 设置推流器水印。默认情况下，水印不开启 |
| [snapshot](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/snapshot.html)                                 | 截取推流过程中的视频画面        |
| [startCamera](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/startCamera.html)                           | 打开本地摄像头             |
| [stopCamera](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/stopCamera.html)                             | 关闭本地摄像头             |
| [startVirtualCamera](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/startVirtualCamera.html)             | 开启图片推流              |
| [stopVirtualCamera](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/stopVirtualCamera.html)               | 关闭图片推流              |
| [startScreenCapture](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/startScreenCapture.html)             | 开启屏幕采集              |
| [stopScreenCapture](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/stopScreenCapture.html)               | 关闭屏幕采集              |

### 美颜相关接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [getBeautyManager](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/getBeautyManager.html)                 | 获取美颜管理对象      |

### 音频相关接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [startMicrophone](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/startMicrophone.html)                   | 打开麦克风               |
| [stopMicrophone](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/stopMicrophone.html)                     | 关闭麦克风               |
| [setAudioQuality](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setAudioQuality.html)                   | 设置推流音频质量                    |
| [enableVolumeEvaluation](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/enableVolumeEvaluation.html)     | 启用采集音量大小提示       |
| [enableCustomAudioCapture](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/enableCustomAudioCapture.html) | 开启/关闭自定义音频采集            |
| [sendCustomAudioFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/sendCustomAudioFrame.html)         | 在自定义音频采集模式下，将采集的音频数据发送到SDK |
| [pauseAudio](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/pauseAudio.html)                             | 暂停推流器的音频流                    |
| [resumeAudio](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/resumeAudio.html)                           | 恢复推流器的音频流                    |

### 音效相关接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [getAudioEffectManager](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/getAudioEffectManager.html)       | 获取音效管理对象      |

### 设备管理相关接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [getDeviceManager](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/getDeviceManager.html)                 | 获取设备管理对象      |

### 更多实用接口

| API                                                                                                                                                   | Description                  |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| [setProperty](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setProperty.html)                           | 调用 V2TXLivePusher 的高级 API 接口 |
| [setMixTranscodingConfig](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/setMixTranscodingConfig.html)   | 设置云端的混流转码参数 |
| [showDebugView](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/showDebugView.html)                       | 显示仪表盘               |
| [sendSeiMessage](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/V2TXLivePusher/sendSeiMessage.html)                     | 发送 SEI 消息 |


## V2TXLivePusherObserver

**功能**

腾讯云直播的推流回调通知。

**介绍**

可以接收 [V2TXLivePusher](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher/v2_tx_live_pusher-library.html) 推流器的一些推流通知，包括推流器连接状态、音视频首帧回调、统计数据、警告和错误信息等。


### SDK 基础回调

| API                                                                                                                                                            | Description         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onError](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onError)                       | 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示 |
| [onWarning](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onWarning)                   | 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败 |
| [onPushStatusUpdate](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onPushStatusUpdate) | 推流器连接状态回调通知 |

### 视频相关回调

| API                                                                                                                                                                        | Description         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onCaptureFirstVideoFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onCaptureFirstVideoFrame) | 首帧视频采集完成的回调通知 |
| [onSnapshotComplete](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onSnapshotComplete)             | 截图回调 |
| [onProcessVideoFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onProcessVideoFrame)           | 自定义视频处理回调 |
| [onGLContextDestroyed](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onGLContextDestroyed)         | SDK 内部的 OpenGL 环境的销毁通知 |
| [onScreenCaptureStarted](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onScreenCaptureStarted)     | 当屏幕分享开始时，SDK 会通过此回调通知 |
| [onScreenCaptureStopped](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onScreenCaptureStopped)     | 当屏幕分享停止时，SDK 会通过此回调通知 |

### 音频相关回调

| API                                                                                                                                                                              | Description         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onCaptureFirstAudioFrame](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onCaptureFirstAudioFrame)       | 首帧音频采集完成的回调通知 |
| [onMicrophoneVolumeUpdate](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onMicrophoneVolumeUpdate)       | 麦克风采集音量值回调 |
| [onMusicObserverStart](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onMusicObserverStart)               | 音频开始播放 |
| [onMusicObserverPlayProgress](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onMusicObserverPlayProgress) | 音频播放中 |
| [onMusicObserverComplete](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onMusicObserverComplete)         | 音频播放结束 |

### 统计回调

| API                                                                                                                                                            | Description         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onStatisticsUpdate](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onStatisticsUpdate) | 直播推流器统计数据回调 |

### 混流回调

| API                                                                                                                                                                            | Description         |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| [onSetMixTranscodingConfig](https://liteav.sdk.qcloud.com/doc/product/live/dart/api/cn/v2_tx_live_pusher_observer/V2TXLivePusherListenerType.html#onSetMixTranscodingConfig)   | 设置云端的混流转码参数的回调 |


