package com.tencent.live.plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.live.utils.Logger;
import com.tencent.live2.V2TXLiveCode;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.live.TXLivePluginDef.V2TXLivePlayerObserverType;
import com.tencent.live.utils.AndroidUtils;
import com.tencent.live.utils.EnumUtils;
import com.tencent.live.utils.MethodUtils;
import com.tencent.live.view.V2LiveRenderViewFactory;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class V2TXLivePlayerPlugin implements MethodChannel.MethodCallHandler {
    private static final String TAG                 = "V2TXLivePlayerPlugin";
    private static final int    TC_COMPONENT_PUSHER = 1;
    private static final int    TC_FRAMEWORK_LIVE   = 23;

    private MethodChannel           mChannel;
    private BinaryMessenger         mMessenger;
    private V2TXLivePlayer          mPlayer;
    private Context                 mContext;
    private String                  mIdentifier;
    private V2LiveRenderViewFactory mTXRenderViewFactory;

    public V2TXLivePlayerPlugin(String identifier, BinaryMessenger messenger, Context context,
                                V2LiveRenderViewFactory txRenderViewFactory) {
        mMessenger = messenger;
        mIdentifier = identifier;
        mContext = context;
        mChannel = new MethodChannel(mMessenger, "player_" + mIdentifier);
        mChannel.setMethodCallHandler(this);
        mPlayer = new V2TXLivePlayerImpl(mContext);
        mPlayer.setObserver(new V2TXLivePlayerObserverImpl());
        mTXRenderViewFactory = txRenderViewFactory;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Logger.info(TAG, "onMethodCall -> method:"
                + call.method + ", arguments:" + call.arguments);
        try {
            Method method = V2TXLivePlayerPlugin.class.getDeclaredMethod(call.method,
                    MethodCall.class, MethodChannel.Result.class);
            method.invoke(this, call, result);
        } catch (NoSuchMethodException e) {
            Logger.error(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        } catch (IllegalAccessException e) {
            Logger.error(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        } catch (Exception e) {
            Logger.error(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        }
    }

    public void destroy() {
        mPlayer.setObserver(null);
        mChannel.setMethodCallHandler(null);
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    播放器相关接口
    //
    /////////////////////////////////////////////////////////////////////////////////
    /**
     * 设置播放器回调。
     * 通过设置回调，可以监听 V2TXLivePlayer 播放器的一些回调事件，
     * 包括播放器状态、播放音量回调、音视频首帧回调、统计数据、警告和错误信息等。
     *
     * @param observer 播放器的回调目标对象，更多信息请查看 {@link V2TXLivePlayerObserver}
     */
    public void setObserver(V2TXLivePlayerObserver observer) {
        //TODO 回调相关 暂未处理
    }

    /**
     * 设置播放器的视频渲染 View。 该控件负责显示视频内容。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public int setRenderView(MethodCall call, MethodChannel.Result result) {
        int viewId = MethodUtils.getMethodParams(call, result, "id");
        int ret = mPlayer.setRenderView((TXCloudVideoView) mTXRenderViewFactory.getViewById(viewId).getView());
        result.success(ret);
        return ret;
    }

    /**
     * 设置播放器画面的旋转角度。
     * rotation 旋转角度 {@link V2TXLiveDef.V2TXLiveRotation}
     * - V2TXLiveRotation0【默认值】: 0度, 不旋转
     * - V2TXLiveRotation90:  顺时针旋转90度
     * - V2TXLiveRotation180: 顺时针旋转180度
     * - V2TXLiveRotation270: 顺时针旋转270度
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setRenderRotation(MethodCall call, MethodChannel.Result result) {
        int rotation = MethodUtils.getMethodParams(call, result, "rotation");
        V2TXLiveDef.V2TXLiveRotation type = EnumUtils.getV2TXLiveRotation(rotation);
        int ret = mPlayer.setRenderRotation(type);
        result.success(ret);
    }

    /**
     * 设置画面的填充模式。
     * mode 画面填充模式 {@link V2TXLiveDef.V2TXLiveFillMode}。
     * - V2TXLiveFillModeFill 【默认值】: 图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉
     * - V2TXLiveFillModeFit: 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setRenderFillMode(MethodCall call, MethodChannel.Result result) {
        int mode = MethodUtils.getMethodParams(call, result, "mode");
        V2TXLiveDef.V2TXLiveFillMode type = EnumUtils.getV2TXLiveFillMode(mode);
        int ret = mPlayer.setRenderFillMode(type);
        result.success(ret);
    }

    /**
     * 开始播放音视频流。
     * url 音视频流的播放地址，支持 RTMP, HTTP-FLV, TRTC。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void startLivePlay(MethodCall call, MethodChannel.Result result) {
        setFramework();
        String url = MethodUtils.getMethodParams(call, result, "url");
        int ret = mPlayer.startLivePlay(url);
        result.success(ret);
    }

    /**
     * 停止播放音视频流。
     */
    public void stopPlay(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.stopPlay();
        result.success(ret);
    }

    /**
     * 播放器是否正在播放中。
     *
     * @return 是否正在播放 1: 正在播放中 0: 已经停止播放
     */
    public void isPlaying(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.isPlaying();
        result.success(ret);
    }

    /**
     * 暂停播放器的音频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void pauseAudio(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.pauseAudio();
        result.success(ret);
    }

    /**
     * 恢复播放器的音频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void resumeAudio(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.resumeAudio();
        result.success(ret);
    }

    /**
     * 暂停播放器的视频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void pauseVideo(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.pauseVideo();
        result.success(ret);
    }

    /**
     * 恢复播放器的视频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void resumeVideo(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.resumeVideo();
        result.success(ret);
    }

    /**
     * 设置播放器音量。
     * volume 音量大小，取值范围0 - 100。【默认值】: 100
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setPlayoutVolume(MethodCall call, MethodChannel.Result result) {
        int volume = MethodUtils.getMethodParams(call, result, "volume");
        int ret = mPlayer.setPlayoutVolume(volume);
        result.success(ret);
    }

    /**
     * 设置播放器缓存自动调整的最小和最大时间 ( 单位：秒 )。
     * minTime 缓存自动调整的最小时间，取值需要大于0。【默认值】：1
     * maxTime 缓存自动调整的最大时间，取值需要大于0。【默认值】：5
     *
     * @return 返回值 {@link V2TXLiveCode}
     * - V2TXLIVE_ERROR_INVALID_PARAMETER: 操作失败，minTime 和 maxTime 需要大于0
     * - V2TXLIVE_ERROR_REFUSED: 播放器处于播放状态，不支持修改缓存策略
     */
    public void setCacheParams(MethodCall call, MethodChannel.Result result) {
        String minTimeStr = MethodUtils.getMethodParams(call, result, "minTime");
        final float minTime = Float.parseFloat(minTimeStr);
        String maxTimeStr = MethodUtils.getMethodParams(call, result, "maxTime");
        final float maxTime = Float.parseFloat(maxTimeStr);
        int ret = mPlayer.setCacheParams(minTime, maxTime);
        result.success(ret);
    }

    /**
     * 启用播放音量大小提示。
     * 开启后可以在 {@link V2TXLivePlayerObserver#onPlayoutVolumeUpdate(V2TXLivePlayer, int)} 回调中获取到 SDK 对音量大小值的评估。
     * intervalMs 决定了 onPlayoutVolumeUpdate 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；【默认值】：0，不开启
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void enableVolumeEvaluation(MethodCall call, MethodChannel.Result result) {
        int intervalMs = MethodUtils.getMethodParams(call, result, "intervalMs");
        int ret = mPlayer.enableVolumeEvaluation(intervalMs);
        result.success(ret);
    }

    /**
     * 截取播放过程中的视频画面。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void snapshot(MethodCall call, MethodChannel.Result result) {
        int ret = mPlayer.snapshot();
        result.success(ret);
    }

    /**
     * 开启/关闭对视频帧的监听回调。
     * SDK 在您开启次此开关后将不再渲染视频画面，您可以通过 V2TXLivePlayerObserver 获得视频帧，并执行自定义的渲染逻辑。
     * enable      是否开启自定义渲染。【默认值】：false
     * pixelFormat 自定义渲染回调的视频像素格式 {@link V2TXLiveDef.V2TXLivePixelFormat}。
     * bufferType  自定义渲染回调的视频数据格式 {@link V2TXLiveDef.V2TXLiveBufferType}。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void enableObserveVideoFrame(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        int pixelFormat = MethodUtils.getMethodParams(call, result, "pixelFormat");
        int bufferType = MethodUtils.getMethodParams(call, result, "bufferType");
        V2TXLiveDef.V2TXLivePixelFormat realPixelFormat = EnumUtils.getV2TXLivePixelFormat(pixelFormat);
        V2TXLiveDef.V2TXLiveBufferType realBufferType = EnumUtils.getV2TXLiveBufferType(bufferType);
        int ret = mPlayer.enableObserveVideoFrame(enable, realPixelFormat, realBufferType);
        result.success(ret);
    }


    /**
     * 开启接收 SEI 消息
     * enable      true: 开启接收 SEI 消息; false: 关闭接收 SEI 消息。【默认值】: false
     * payloadType 指定接收 SEI 消息的 payloadType，支持 5、242，请与发送端的 payloadType 保持一致。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void enableReceiveSeiMessage(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        int payloadType = MethodUtils.getMethodParams(call, result, "payloadType");
        int ret = mPlayer.enableReceiveSeiMessage(enable, payloadType);
        result.success(ret);
    }

    /**
     * 是否显示播放器状态信息的调试浮层。
     * isShow 是否显示。【默认值】：false
     */
    public void showDebugView(MethodCall call, MethodChannel.Result result) {
        boolean isShow = MethodUtils.getMethodParams(call, result, "isShow");
        mPlayer.showDebugView(isShow);
        result.success(0);
    }

    /**
     * 调用 V2TXLivePlayer 的高级 API 接口。
     * key   高级 API 对应的 key。
     * value 调用 key 所对应的高级 API 时，需要的参数。
     *
     * @return 返回值 {@link V2TXLiveCode}
     * @note 该接口用于调用一些高级功能。
     */
    public void setProperty(MethodCall call, MethodChannel.Result result) {
        String key = MethodUtils.getMethodParams(call, result, "key");
        Object value = MethodUtils.getMethodParams(call, result, "value");
        int ret = mPlayer.setProperty(key, value);
        result.success(ret);
    }

    public void enablePictureInPicture(MethodCall call, MethodChannel.Result result) {
        Logger.error(TAG, "Not support PictureInPicture");
        result.success(V2TXLiveCode.V2TXLIVE_ERROR_NOT_SUPPORTED);
    }

    class V2TXLivePlayerObserverImpl extends V2TXLivePlayerObserver {

        /**
         * 直播播放器错误通知，播放器出现错误时，会回调该通知
         *
         * @param player    回调该通知的播放器对象
         * @param code      错误码 {@link V2TXLiveCode}
         * @param msg       错误信息
         * @param extraInfo 扩展信息
         */
        public void onError(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("errCode", code);
            map.put("errMsg", msg);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onError"), map);
        }

        /**
         * 直播播放器警告通知
         *
         * @param player    回调该通知的播放器对象
         * @param code      警告码 {@link V2TXLiveCode}
         * @param msg       警告信息
         * @param extraInfo 扩展信息
         */
        public void onWarning(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("errCode", code);
            map.put("errMsg", msg);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onWarning"), map);
        }

        /**
         * 直播播放器分辨率变化通知
         *
         * @param player 回调该通知的播放器对象
         * @param width  视频宽
         * @param height 视频高
         */
        public void onVideoResolutionChanged(V2TXLivePlayer player, int width, int height) {
            Map map = new HashMap();
            map.put("width", width);
            map.put("height", height);
            invokeListener(V2TXLivePlayerObserverType.getByName("onVideoResolutionChanged"), map);
        }

        /**
         * 已经成功连接到服务器
         *
         * @param player    回调该通知的播放器对象
         * @param extraInfo 扩展信息
         */
        public void onConnected(V2TXLivePlayer player, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onConnected"), map);
        }

        /**
         * 视频播放事件
         *
         * @param player    回调该通知的播放器对象
         * @param firstPlay 第一次播放标志
         * @param extraInfo 扩展信息
         */
        public void onVideoPlaying(V2TXLivePlayer player, boolean firstPlay, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("firstPlay", firstPlay);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onVideoPlaying"), map);
        }

        /**
         * 音频播放事件
         *
         * @param player    回调该通知的播放器对象
         * @param firstPlay 第一次播放标志
         * @param extraInfo 扩展信息
         */
        public void onAudioPlaying(V2TXLivePlayer player, boolean firstPlay, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("firstPlay", firstPlay);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onAudioPlaying"), map);
        }

        /**
         * 视频加载事件
         *
         * @param player    回调该通知的播放器对象
         * @param extraInfo 扩展信息
         */
        public void onVideoLoading(V2TXLivePlayer player, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onVideoLoading"), map);
        }

        /**
         * 音频加载事件
         *
         * @param player    回调该通知的播放器对象
         * @param extraInfo 扩展信息
         */
        public void onAudioLoading(V2TXLivePlayer player, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePlayerObserverType.getByName("onAudioLoading"), map);
        }

        /**
         * 播放器音量大小回调
         *
         * @param player 回调该通知的播放器对象
         * @param volume 音量大小
         * @note 调用 {@link V2TXLivePlayer#enableVolumeEvaluation(int)} 开启播放音量大小提示之后，会收到这个回调通知。
         */
        public void onPlayoutVolumeUpdate(V2TXLivePlayer player, int volume) {
            Map map = new HashMap();
            map.put("volume", volume);
            invokeListener(V2TXLivePlayerObserverType.getByName("onPlayoutVolumeUpdate"), map);
        }

        /**
         * 直播播放器统计数据回调
         *
         * @param player     回调该通知的播放器对象
         * @param statistics 播放器统计数据 {@link V2TXLiveDef.V2TXLivePlayerStatistics}
         */
        public void onStatisticsUpdate(V2TXLivePlayer player, V2TXLiveDef.V2TXLivePlayerStatistics statistics) {
            Map map = new HashMap();
            map.put("appCpu", statistics.appCpu);
            map.put("systemCpu", statistics.systemCpu);
            map.put("width", statistics.width);
            map.put("height", statistics.height);
            map.put("fps", statistics.fps);
            map.put("videoBitrate", statistics.videoBitrate);
            map.put("audioBitrate", statistics.audioBitrate);
            invokeListener(V2TXLivePlayerObserverType.getByName("onStatisticsUpdate"), map);
        }

        /**
         * 截图回调
         *
         * @param player 回调该通知的播放器对象
         * @param image  已截取的视频画面
         */
        public void onSnapshotComplete(V2TXLivePlayer player, Bitmap image) {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            image.compress(Bitmap.CompressFormat.JPEG, 100, baos);
            byte[] datas = baos.toByteArray();
            Map map = new HashMap();
            map.put("image", datas);
            invokeListener(V2TXLivePlayerObserverType.getByName("onSnapshotComplete"), map);
        }

        /**
         * 自定义视频渲染回调
         *
         * @param player     回调该通知的播放器对象
         * @param videoFrame 视频帧数据 {@link V2TXLiveDef.V2TXLiveVideoFrame}
         */
        public void onRenderVideoFrame(V2TXLivePlayer player, V2TXLiveDef.V2TXLiveVideoFrame videoFrame) {
            Map map = new HashMap();
            map.put("videoFrame", MethodUtils.handleVideoFrame(videoFrame));
            invokeListener(V2TXLivePlayerObserverType.getByName("onRenderVideoFrame"), map);
        }

        /**
         * 收到 SEI 消息的回调，发送端通过 {@link V2TXLivePusher} 中的 `sendSeiMessage` 来发送 SEI 消息。
         *
         * @param player      回调该通知的播放器对象。
         * @param payloadType 回调数据的SEI payloadType
         * @param data        数据
         * @note 调用 {@link V2TXLivePlayer} 中的 `enableReceiveSeiMessage` 开启接收 SEI 消息之后，会收到这个回调通知
         */
        public void onReceiveSeiMessage(V2TXLivePlayer player, int payloadType, byte[] data) {
            Map map = new HashMap();
            map.put("payloadType", payloadType);
            map.put("data", data);
            invokeListener(V2TXLivePlayerObserverType.getByName("onReceiveSeiMessage"), map);
        }

        public void invokeListener(V2TXLivePlayerObserverType type, Map map) {
            Log.d(TAG, "invokeListener type:" + type.getName());
            Map resultParams = new HashMap();
            resultParams.put("type", type.getName());
            if (map != null) {
                resultParams.put("params", map);
            }
            /// 方法名唯一， Type区分使用那个方法
            mChannel.invokeMethod("onPlayerListener", resultParams);
        }
    }

    private void setFramework() {
        try {
            JSONObject params = new JSONObject();
            params.put("framework", TC_FRAMEWORK_LIVE);
            params.put("component", TC_COMPONENT_PUSHER);
            mPlayer.setProperty("setFramework", params.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
