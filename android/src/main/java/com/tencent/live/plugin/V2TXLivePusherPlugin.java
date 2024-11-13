package com.tencent.live.plugin;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import androidx.core.content.ContextCompat;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.live.TXLivePluginManager;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesser;
import com.tencent.live.beauty.custom.TXCustomBeautyDef;
import com.tencent.live.utils.Logger;
import com.tencent.live2.V2TXLiveCode;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.live.TXLivePluginDef;
import com.tencent.live.TXLivePluginDef.V2TXLivePusherObserverType;
import com.tencent.live.utils.AndroidUtils;
import com.tencent.live.utils.EnumUtils;
import com.tencent.live.utils.MethodUtils;
import com.tencent.live.view.V2LiveRenderViewFactory;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_WARNING_CAMERA_NO_PERMISSION;
import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_WARNING_MICROPHONE_NO_PERMISSION;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyBufferType;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyPixelFormat;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyVideoFrame;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteArray;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteBuffer;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeUnknown;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatI420;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatTexture2D;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatUnknown;

public class V2TXLivePusherPlugin implements MethodChannel.MethodCallHandler {
    private static final String TAG                 = "V2TXLivePusherPlugin";
    private static final int    TC_COMPONENT_PUSHER = 1;
    private static final int    TC_FRAMEWORK_LIVE   = 23;

    private MethodChannel               mChannel;
    private BinaryMessenger             mMessenger;
    private V2TXLivePusher              mPusher;
    private String                      mIdentifier;
    private Context                     mContext;
    private FlutterPlugin.FlutterAssets mFlutterAssets;
    private TXAudioEffectManager        mTXAudioEffectManager;
    private TXBeautyManager             mTXBeautyManager;
    private TXDeviceManager             mTXDeviceManager;
    private V2LiveRenderViewFactory     mTXRenderViewFactory;
    private ITXCustomBeautyProcesser    mCustomBeautyProcesser;


    public V2TXLivePusherPlugin(String identifier, int mode, BinaryMessenger messenger, Context context,
                                FlutterPlugin.FlutterAssets flutterAssets,
                                V2LiveRenderViewFactory txRenderViewFactory) {
        mMessenger = messenger;
        mIdentifier = identifier;
        mContext = context;
        mFlutterAssets = flutterAssets;
        mChannel = new MethodChannel(mMessenger, "pusher_" + mIdentifier);
        mChannel.setMethodCallHandler(this);
        if (mode == 0) {
            mPusher = new V2TXLivePusherImpl(mContext, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTMP);
        } else {
            mPusher = new V2TXLivePusherImpl(mContext, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);
        }
        mPusher.setObserver(new V2TXLivePusherObserverImpl());
        mTXRenderViewFactory = txRenderViewFactory;
        mTXBeautyManager = mPusher.getBeautyManager();
        mTXDeviceManager = mPusher.getDeviceManager();
        mTXAudioEffectManager = mPusher.getAudioEffectManager();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Logger.info(TAG, "onMethodCall -> method:"
                + call.method + ", arguments:" + call.arguments);
        try {
            Method method = V2TXLivePusherPlugin.class.getDeclaredMethod(
                    call.method, MethodCall.class, MethodChannel.Result.class);
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
        mPusher.setObserver(null);
        mChannel.setMethodCallHandler(null);
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    推流器相关接口
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 设置推流器回调。
     * 通过设置回调，可以监听 V2TXLivePusher 推流器的一些回调事件，
     * 包括推流器状态、音量回调、统计数据、警告和错误信息等。
     *
     * @param observer 推流器的回调目标对象，更多信息请查看 {@link V2TXLivePusherObserver}
     */
    public void setObserver(V2TXLivePusherObserver observer) {
        //TODO 回调相关暂未实现
    }

    /**
     * 设置本地摄像头预览 View。
     * 本地摄像头采集到的画面，经过美颜、脸形调整、滤镜等多种效果叠加之后，最终会显示到传入的 View 上。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public int setRenderView(MethodCall call, MethodChannel.Result result) {
        int viewId = MethodUtils.getMethodParams(call, result, "id");
        int ret = mPusher.setRenderView((TXCloudVideoView) mTXRenderViewFactory.getViewById(viewId).getView());
        result.success(ret);
        return ret;
    }

    /**
     * 设置本地摄像头预览镜像。
     * 本地摄像头分为前置摄像头和后置摄像头，系统默认情况下，是前置摄像头镜像，后置摄像头不镜像，这里可以修改前置后置摄像头的默认镜像类型。
     * mirrorType 摄像头镜像类型 {@link V2TXLiveDef.V2TXLiveMirrorType}
     * - V2TXLiveMirrorTypeAuto  【默认值】: 默认镜像类型. 在这种情况下，前置摄像头的画面是镜像的，后置摄像头的画面不是镜像的
     * - V2TXLiveMirrorTypeEnable:  前置摄像头 和 后置摄像头，都切换为镜像模式
     * - V2TXLiveMirrorTypeDisable: 前置摄像头 和 后置摄像头，都切换为非镜像模式
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setRenderMirror(MethodCall call, MethodChannel.Result result) {
        int mirrorType = MethodUtils.getMethodParams(call, result, "mirrorType");
        V2TXLiveDef.V2TXLiveMirrorType type = EnumUtils.getV2TXLiveMirrorType(mirrorType);
        int ret = mPusher.setRenderMirror(type);
        result.success(ret);
    }

    /**
     * 设置视频编码镜像。
     * 编码镜像只影响观众端看到的视频效果。
     * mirror 是否镜像
     * - false【默认值】: 播放端看到的是非镜像画面
     * - true: 播放端看到的是镜像画面
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setEncoderMirror(MethodCall call, MethodChannel.Result result) {
        boolean mirror = MethodUtils.getMethodParams(call, result, "mirror");
        int ret = mPusher.setEncoderMirror(mirror);
        result.success(ret);
    }

    /**
     * 设置本地摄像头预览画面的旋转角度。
     * 只旋转本地预览画面，不影响推流出去的画面。
     * rotation 预览画面的旋转角度 {@link V2TXLiveDef.V2TXLiveRotation}
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
        int ret = mPusher.setRenderRotation(type);
        result.success(ret);
    }

    /**
     * 打开本地摄像头。
     * frontCamera 指定摄像头方向是否为前置
     * - true 【默认值】: 切换到前置摄像头
     * - false: 切换到后置摄像头
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void startCamera(MethodCall call, MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            int checkResult = ContextCompat.checkSelfPermission(mContext, Manifest.permission.CAMERA);
            if (checkResult != PackageManager.PERMISSION_GRANTED) {
                result.success(V2TXLIVE_WARNING_CAMERA_NO_PERMISSION);
                return;
            }
        }
        boolean frontCamera = MethodUtils.getMethodParams(call, result, "frontCamera");
        int ret = mPusher.startCamera(frontCamera);
        result.success(ret);
    }

    /**
     * 关闭本地摄像头。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void stopCamera(MethodCall call, MethodChannel.Result result) {
        mPusher.stopCamera();
        result.success(0);
    }

    /**
     * 打开麦克风。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void startMicrophone(MethodCall call, MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            int checkResult = ContextCompat.checkSelfPermission(mContext, Manifest.permission.RECORD_AUDIO);
            if (checkResult != PackageManager.PERMISSION_GRANTED) {
                result.success(V2TXLIVE_WARNING_MICROPHONE_NO_PERMISSION);
                return;
            }
        }
        int ret = mPusher.startMicrophone();
        result.success(ret);
    }

    /**
     * 关闭麦克风。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void stopMicrophone(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.stopMicrophone();
        result.success(ret);
    }

    /**
     * 开启图片推流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void startVirtualCamera(MethodCall call, final MethodChannel.Result result) {
        String type = MethodUtils.getMethodParams(call, result, "type");
        final String imageUrl = MethodUtils.getMethodParams(call, result, "imageUrl");
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        mPusher.startVirtualCamera(myBitmap);
                    } catch (IOException e) {
                        Log.e(TAG, "|method=startVirtualCamera|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = mFlutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = mContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                mPusher.startVirtualCamera(myBitmap);

            } catch (Exception e) {
                Log.e(TAG, "|method=startVirtualCamera|error=" + e);
            }
        }
        result.success(null);
    }

    /**
     * 关闭图片推流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void stopVirtualCamera(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.stopVirtualCamera();
        result.success(ret);
    }

    /**
     * 开启屏幕采集。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void startScreenCapture(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.startScreenCapture();
        result.success(ret);
    }

    /**
     * 关闭屏幕采集。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void stopScreenCapture(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.stopScreenCapture();
        result.success(ret);
    }

    /**
     * 暂停推流器的音频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void pauseAudio(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.pauseAudio();
        result.success(ret);
    }

    /**
     * 恢复推流器的音频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void resumeAudio(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.resumeAudio();
        result.success(ret);
    }

    /**
     * 暂停推流器的视频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void pauseVideo(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.pauseVideo();
        result.success(ret);
    }

    /**
     * 恢复推流器的视频流。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void resumeVideo(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.resumeVideo();
        result.success(ret);
    }

    /**
     * 开始音视频数据推流。
     * <p>
     * url 推流的目标地址，支持任意推流服务端
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void startPush(MethodCall call, MethodChannel.Result result) {
        setFramework();
        String url = MethodUtils.getMethodParams(call, result, "url");
        int ret = mPusher.startPush(url);
        result.success(ret);
    }

    /**
     * 停止推送音视频数据。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void stopPush(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.stopPush();
        result.success(ret);
    }

    /**
     * 当前推流器是否正在推流中。
     *
     * @return 是否正在推流
     */
    public void isPushing(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.isPushing();
        result.success(ret);
    }

    /**
     * 设置推流音频质量。
     * <p
     * quality 音频质量 {@link V2TXLiveDef.V2TXLiveAudioQuality}
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setAudioQuality(MethodCall call, MethodChannel.Result result) {
        int quality = MethodUtils.getMethodParams(call, result, "quality");
        V2TXLiveDef.V2TXLiveAudioQuality type = EnumUtils.getV2TXLiveAudioQuality(quality);
        int ret = mPusher.setAudioQuality(type);
        result.success(ret);
    }

    /**
     * 设置推流视频编码参数
     * param 视频编码参数 {@link V2TXLiveDef.V2TXLiveVideoEncoderParam}
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setVideoQuality(MethodCall call, MethodChannel.Result result) {
        int videoFps = MethodUtils.getMethodParams(call, result, "videoFps");
        int videoBitrate = MethodUtils.getMethodParams(call, result, "videoBitrate");
        int minVideoBitrate = MethodUtils.getMethodParams(call, result, "minVideoBitrate");
        int videoResolution = MethodUtils.getMethodParams(call, result, "videoResolution");
        int videoResolutionMode = MethodUtils.getMethodParams(call, result, "videoResolutionMode");
        final V2TXLiveDef.V2TXLiveVideoResolution reesolutionType =
                EnumUtils.getV2TXLiveVideoResolution(videoResolution);
        final V2TXLiveDef.V2TXLiveVideoResolutionMode resolutionMode =
                EnumUtils.getV2TXLiveVideoResolutionMode(videoResolutionMode);

        V2TXLiveDef.V2TXLiveVideoEncoderParam param = new V2TXLiveDef.V2TXLiveVideoEncoderParam(reesolutionType);
        param.minVideoBitrate = minVideoBitrate;
        param.videoBitrate = videoBitrate;
        param.videoFps = videoFps;
        param.videoResolutionMode = resolutionMode;
        int ret = mPusher.setVideoQuality(param);
        result.success(ret);
    }

    /**
     * 获取音效管理对象 {@link TXAudioEffectManager}。
     */
    public void getAudioEffectManager(MethodCall call, MethodChannel.Result result) {
        mTXAudioEffectManager = mPusher.getAudioEffectManager();
        result.success(0);
    }

    /**
     * 获取美颜管理对象 {@link TXBeautyManager}。
     */
    public void getBeautyManager(MethodCall call, MethodChannel.Result result) {
        mTXBeautyManager = mPusher.getBeautyManager();
        result.success(0);
    }

    /**
     * 获取设备管理对象 {@link TXDeviceManager}。
     */
    public void getDeviceManager(MethodCall call, MethodChannel.Result result) {
        mTXDeviceManager = mPusher.getDeviceManager();
        result.success(0);
    }

    /**
     * 截取推流过程中的本地画面。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void snapshot(MethodCall call, MethodChannel.Result result) {
        int ret = mPusher.snapshot();
        result.success(ret);
    }

    /**
     * 设置推流器水印。默认情况下，水印不开启。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setWatermark(MethodCall call, MethodChannel.Result result) {
        final String imageUrl = MethodUtils.getMethodParams(call, result, "image");
        String type = MethodUtils.getMethodParams(call, result, "type");
        String xStr = MethodUtils.getMethodParams(call, result, "x");
        final float x = Float.parseFloat(xStr);
        String yStr = MethodUtils.getMethodParams(call, result, "y");
        final float y = Float.parseFloat(yStr);
        String scaleStr = MethodUtils.getMethodParams(call, result, "scale");
        final float scale = Float.parseFloat(scaleStr);
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        int ret = mPusher.setWatermark(myBitmap, x, y, scale);
                        result.success(ret);
                    } catch (IOException e) {
                        Log.e(TAG, "|method=setWatermark|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = mFlutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = mContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                int ret = mPusher.setWatermark(myBitmap, x, y, scale);
                result.success(ret);
            } catch (Exception e) {
                Log.e(TAG, "|method=setWatermark|error=" + e);
            }
        }
    }

    /**
     * 启用采集音量大小提示。
     * 开启后可以在 {@link V2TXLivePusherObserver#onMicrophoneVolumeUpdate(int)} 回调中获取到 SDK 对音量大小值的评估。
     * intervalMs 决定了 onMicrophoneVolumeUpdate 回调的触发间隔，单位为ms，
     * 最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；【默认值】：0，不开启
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void enableVolumeEvaluation(MethodCall call, MethodChannel.Result result) {
        int intervalMs = MethodUtils.getMethodParams(call, result, "intervalMs");
        int ret = mPusher.enableVolumeEvaluation(intervalMs);
        result.success(ret);
    }

    /**
     * 开启/关闭自定义视频处理。
     * enable true: 开启; false: 关闭。【默认值】: false
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void enableCustomVideoProcess(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        ITXCustomBeautyProcesserFactory processerFactory = TXLivePluginManager.getBeautyProcesserFactory();
        if (processerFactory == null) {
            result.error("Missing parameter", "beautyInstance is null!!!",
                    TXLivePluginDef.ErrorCode.CODE_VALUEISNULL);
            return;
        }
        mCustomBeautyProcesser = processerFactory.createCustomBeautyProcesser();
        TXCustomBeautyBufferType bufferType = mCustomBeautyProcesser.getSupportedBufferType();
        TXCustomBeautyPixelFormat pixelFormat = mCustomBeautyProcesser.getSupportedPixelFormat();
        int ret = mPusher.enableCustomVideoProcess(enable,
                convertV2LivePixelFormat(pixelFormat), convertV2LiveBufferType(bufferType));
        result.success(ret);
    }

    /**
     * 开启/关闭自定义视频采集。
     * 在自定义视频采集模式下，SDK 不再从摄像头采集图像，只保留编码和发送能力。
     * enable true：开启自定义采集；false：关闭自定义采集。【默认值】：false
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void enableCustomVideoCapture(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        int ret = mPusher.enableCustomVideoCapture(enable);
        result.success(ret);
    }

    /**
     * 开启/关闭自定义音频采集
     * enable true: 开启自定义采集; false: 关闭自定义采集。【默认值】: false
     *
     * @return 返回值 {@link V2TXLiveCode}
     * 在自定义音频采集模式下，SDK 不再从麦克风采集声音，只保留编码和发送能力。
     * @note 需要在 [startPush]({@link V2TXLivePusher#startPush(String)}) 前调用才会生效。
     */
    public void enableCustomAudioCapture(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        int ret = mPusher.enableCustomAudioCapture(enable);
        result.success(ret);
    }

    /**
     * 在自定义视频采集模式下，将采集的视频数据发送到SDK。
     * 在自定义视频采集模式下，SDK不再采集摄像头数据，仅保留编码和发送功能。
     *
     * @param videoFrame 向 SDK 发送的 视频帧数据 {@link V2TXLiveDef.V2TXLiveVideoFrame}
     * @return 返回值 {@link V2TXLiveCode}
     */
    public int sendCustomVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame videoFrame) {
        //TODO 复杂对象暂未处理
        return -1;
    }

    /**
     * 在自定义音频采集模式下，将采集的音频数据发送到SDK
     *
     * @param audioFrame 向 SDK 发送的 音频帧数据 {@link V2TXLiveDef.V2TXLiveAudioFrame}
     * @return 返回值 {@link V2TXLiveCode}
     * @brief 在自定义音频采集模式下，将采集的音频数据发送到SDK，SDK不再采集麦克风数据，仅保留编码和发送功能。
     */
    public int sendCustomAudioFrame(V2TXLiveDef.V2TXLiveAudioFrame audioFrame) {
        //TODO 复杂对象暂未处理
        return -1;
    }

    /**
     * 发送 SEI 消息
     * 播放端 {@link V2TXLivePlayer} 通过 {@link V2TXLivePlayerObserver} 中的  `onReceiveSeiMessage` 回调来接收该消息。
     * payloadType 数据类型，支持 5、242。推荐填：242
     * data        待发送的数据
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void sendSeiMessage(MethodCall call, MethodChannel.Result result) {
        int payloadType = MethodUtils.getMethodParams(call, result, "payloadType");
        byte[] data = MethodUtils.getMethodParams(call, result, "data");
        int ret = mPusher.sendSeiMessage(payloadType, data);
        result.success(ret);
    }

    /**
     * 显示仪表盘。
     * isShow 是否显示。【默认值】：false
     */
    public void showDebugView(MethodCall call, MethodChannel.Result result) {
        boolean isShow = MethodUtils.getMethodParams(call, result, "isShow");
        mPusher.showDebugView(isShow);
        result.success(0);
    }

    /**
     * 调用 V2TXLivePusher 的高级 API 接口。
     * key   高级 API 对应的 key。
     * value 调用 key 所对应的高级 API 时，需要的参数。
     *
     * @return 返回值 {@link V2TXLiveCode}
     */
    public void setProperty(MethodCall call, MethodChannel.Result result) {
        String key = MethodUtils.getMethodParams(call, result, "key");
        Object value = MethodUtils.getMethodParams(call, result, "value");
        int ret = mPusher.setProperty(key, value);
        result.success(ret);
    }

    /**
     * 设置云端的混流转码参数
     * 如果您在实时音视频 [控制台](https://console.cloud.tencent.com/trtc/) 中的功能配置页开启了“启用旁路推流”功能，
     * 房间里的每一路画面都会有一个默认的直播 [CDN 地址](https://cloud.tencent.com/document/product/647/16826)
     * 一个直播间中可能有不止一位主播，而且每个主播都有自己的画面和声音，但对于 CDN 观众来说，他们只需要一路直播流
     * 所以您需要将多路音视频流混成一路标准的直播流，这就需要混流转码
     * 当您调用 setMixTranscodingConfig() 接口时，SDK 会向腾讯云的转码服务器发送一条指令，目的是将房间里的多路音视频流混合为一路,
     * 您可以通过 mixStreams 参数来调整每一路画面的位置，以及是否只混合声音，也可以通过 videoWidth、videoHeight、videoBitrate 等参数控制混合音视频流的编码参数
     *
     * <pre>
     * 【画面1】=> 解码 ====> \
     *                         \
     * 【画面2】=> 解码 =>  画面混合 => 编码 => 【混合后的画面】
     *                         /
     * 【画面3】=> 解码 ====> /
     *
     * 【声音1】=> 解码 ====> \
     *                         \
     * 【声音2】=> 解码 =>  声音混合 => 编码 => 【混合后的声音】
     *                         /
     * 【声音3】=> 解码 ====> /
     * 参考文档：[云端混流转码](https://cloud.tencent.com/document/product/647/16827)
     * config 请参考 V2TXLiveDef.java 中关于 {@link V2TXLiveDef.V2TXLiveTranscodingConfig} 的介绍。如果传入 null 则取消云端混流转码
     *
     * @return 返回值 {@link V2TXLiveCode}
     * @note 关于云端混流的注意事项：
     * - 仅支持 RTC 模式混流
     * - 云端转码会引入一定的 CDN 观看延时，大概会增加1 - 2秒
     * - 调用该函数的用户，会将连麦中的多路画面混合到自己当前这路画面或者 config 中指定的 streamId 上
     * - 请注意，若您还在房间中且不再需要混流，请务必传入 null 进行取消，因为当您发起混流后，云端混流模块就会开始工作，不及时取消混流可能会引起不必要的计费损失
     * - 请放心，您退房时会自动取消混流状态
     */
    public void setMixTranscodingConfig(MethodCall call, MethodChannel.Result result) {
        Map configMap = MethodUtils.getMethodParams(call, result, "config");
        V2TXLiveDef.V2TXLiveTranscodingConfig config = getMixTranscodingConfigByMap(configMap);
        Log.d(TAG, "setMixTranscodingConfig:" + new Gson().toJson(config));
        int ret = mPusher.setMixTranscodingConfig(config);
        result.success(ret);
    }

    private V2TXLiveDef.V2TXLiveTranscodingConfig getMixTranscodingConfigByMap(Map map) {
        if (map == null || map.isEmpty()) {
            return null;
        }
        V2TXLiveDef.V2TXLiveTranscodingConfig mixConfig = new V2TXLiveDef.V2TXLiveTranscodingConfig();
        if (map.containsKey("videoWidth")) {
            mixConfig.videoWidth = (int) map.get("videoWidth");
        }
        if (map.containsKey("videoHeight")) {
            mixConfig.videoHeight = (int) map.get("videoHeight");
        }
        if (map.containsKey("videoBitrate")) {
            mixConfig.videoBitrate = (int) map.get("videoBitrate");
        }
        if (map.containsKey("videoFramerate")) {
            mixConfig.videoFramerate = (int) map.get("videoFramerate");
        }
        if (map.containsKey("videoGOP")) {
            mixConfig.videoGOP = (int) map.get("videoGOP");
        }
        if (map.containsKey("backgroundColor")) {
            mixConfig.backgroundColor = (int) map.get("backgroundColor");
        }
        if (map.containsKey("backgroundImage")) {
            mixConfig.backgroundImage = (String) map.get("backgroundImage");
        }
        if (map.containsKey("audioSampleRate")) {
            mixConfig.audioSampleRate = (int) map.get("audioSampleRate");
        }
        if (map.containsKey("audioBitrate")) {
            mixConfig.audioBitrate = (int) map.get("audioBitrate");
        }
        if (map.containsKey("audioChannels")) {
            mixConfig.audioChannels = (int) map.get("audioChannels");
        }
        if (map.containsKey("mixStreams")) {
            List list = (List) map.get("mixStreams");
            if (list != null && list.size() > 0) {
                mixConfig.mixStreams = getV2TXLiveMixStreamByList(list);
            }
        }

        if (mixConfig.mixStreams == null) {
            // 默认赋值。sdk有bug：mixStreams没有判空就直接使用，从而引发崩溃。
            mixConfig.mixStreams = new ArrayList<>();
        }

        if (map.containsKey("outputStreamId")) {
            mixConfig.outputStreamId = (String) map.get("outputStreamId");
        }
        return mixConfig;
    }

    private ArrayList<V2TXLiveDef.V2TXLiveMixStream> getV2TXLiveMixStreamByList(List list) {
        ArrayList<V2TXLiveDef.V2TXLiveMixStream> mixStreams = new ArrayList<>();
        if (list == null) {
            return mixStreams;
        }
        for (int i = 0; i < list.size(); i++) {
            Map streamMix = (Map) list.get(i);
            V2TXLiveDef.V2TXLiveMixStream item = new V2TXLiveDef.V2TXLiveMixStream();

            if (streamMix.containsKey("userId")) {
                item.userId = (String) streamMix.get("userId");
            }
            if (streamMix.containsKey("streamId")) {
                item.streamId = (String) streamMix.get("streamId");
            }
            if (streamMix.containsKey("x")) {
                item.x = (int) streamMix.get("x");
            }
            if (streamMix.containsKey("y")) {
                item.y = (int) streamMix.get("y");
            }
            if (streamMix.containsKey("width")) {
                item.width = (int) streamMix.get("width");
            }
            if (streamMix.containsKey("height")) {
                item.height = (int) streamMix.get("height");
            }
            if (streamMix.containsKey("zOrder")) {
                item.zOrder = (int) streamMix.get("zOrder");
            }
            if (streamMix.containsKey("inputType")) {
                int inputType = (int) streamMix.get("inputType");
                item.inputType = EnumUtils.getV2TXLiveMixInputType(inputType);
            }
            mixStreams.add(item);
        }
        return mixStreams;
    }

    class V2TXMusicPlayObserverImpl implements TXAudioEffectManager.TXMusicPlayObserver {
        @Override
        public void onStart(int i, int i1) {
            Map map = new HashMap();
            map.put("id", i);
            map.put("errCode", i1);
            invokeListener(V2TXLivePusherObserverType.getByName("onMusicObserverStart"), map);
        }

        @Override
        public void onPlayProgress(int i, long l, long l1) {
            Map map = new HashMap();
            map.put("id", i);
            map.put("progressMs", l);
            map.put("durationMs", l1);
            invokeListener(V2TXLivePusherObserverType.getByName("onMusicObserverPlayProgress"), map);
        }

        @Override
        public void onComplete(int i, int i1) {
            Map map = new HashMap();
            map.put("id", i);
            map.put("errCode", i1);
            invokeListener(V2TXLivePusherObserverType.getByName("onMusicObserverComplete"), map);
        }

        public void invokeListener(V2TXLivePusherObserverType type, Map map) {
            Log.d(TAG, "invokeListener type:" + type.getName());
            Map resultParams = new HashMap();
            resultParams.put("type", type.getName());
            if (map != null) {
                resultParams.put("params", map);
            }
            /// 方法名唯一， Type区分使用那个方法
            if (mChannel != null) {
                mChannel.invokeMethod("onPusherListener", resultParams);
            }
        }
    }

    class V2TXLivePusherObserverImpl extends V2TXLivePusherObserver {
        /**
         * 直播推流器错误通知，推流器出现错误时，会回调该通知
         *
         * @param code      错误码 {@link V2TXLiveCode}
         * @param msg       错误信息
         * @param extraInfo 扩展信息
         */
        public void onError(int code, String msg, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("errCode", code);
            map.put("errMsg", msg);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePusherObserverType.getByName("onError"), map);
        }

        /**
         * 直播推流器警告通知
         *
         * @param code      警告码 {@link V2TXLiveCode}
         * @param msg       警告信息
         * @param extraInfo 扩展信息
         */
        public void onWarning(int code, String msg, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("errCode", code);
            map.put("errMsg", msg);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePusherObserverType.getByName("onWarning"), map);

        }

        /**
         * 首帧音频采集完成的回调通知
         */
        public void onCaptureFirstAudioFrame() {
            invokeListener(V2TXLivePusherObserverType.getByName("onCaptureFirstAudioFrame"),
                    Collections.emptyMap());
        }

        /**
         * 首帧视频采集完成的回调通知
         */
        public void onCaptureFirstVideoFrame() {
            Log.d(TAG, "onCaptureFirstVideoFrame");
            invokeListener(V2TXLivePusherObserverType.getByName("onCaptureFirstVideoFrame"),
                    Collections.emptyMap());
        }

        /**
         * 麦克风采集音量值回调
         *
         * @param volume 音量大小
         * @note 调用 {@link V2TXLivePusher#enableVolumeEvaluation(int)} 开启采集音量大小提示之后，会收到这个回调通知。
         */
        public void onMicrophoneVolumeUpdate(int volume) {
            Map map = new HashMap();
            map.put("volume", volume);
            invokeListener(V2TXLivePusherObserverType.getByName("onMicrophoneVolumeUpdate"), map);
        }

        /**
         * 推流器连接状态回调通知
         *
         * @param status    推流器连接状态 {@link V2TXLiveDef.V2TXLivePushStatus}
         * @param msg       连接状态信息
         * @param extraInfo 扩展信息
         */
        public void onPushStatusUpdate(V2TXLiveDef.V2TXLivePushStatus status, String msg, Bundle extraInfo) {
            Map map = new HashMap();
            map.put("status", status.name());
            map.put("errMsg", msg);
            map.put("extraInfo", AndroidUtils.getMapByBundle(extraInfo));
            invokeListener(V2TXLivePusherObserverType.getByName("onPushStatusUpdate"), map);
        }

        /**
         * 直播推流器统计数据回调
         *
         * @param statistics 推流器统计数据 {@link V2TXLiveDef.V2TXLivePusherStatistics}
         */
        public void onStatisticsUpdate(V2TXLiveDef.V2TXLivePusherStatistics statistics) {
            Map map = new HashMap();
            map.put("appCpu", statistics.appCpu);
            map.put("systemCpu", statistics.systemCpu);
            map.put("width", statistics.width);
            map.put("height", statistics.height);
            map.put("fps", statistics.fps);
            map.put("videoBitrate", statistics.videoBitrate);
            map.put("audioBitrate", statistics.audioBitrate);
            invokeListener(V2TXLivePusherObserverType.getByName("onStatisticsUpdate"), map);
        }

        /**
         * 截图回调
         *
         * @param image 已截取的视频画面
         * @note 调用 {@link V2TXLivePusher#snapshot()} 截图之后，会收到这个回调通知
         */
        public void onSnapshotComplete(Bitmap image) {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            image.compress(Bitmap.CompressFormat.JPEG, 100, baos);
            byte[] datas = baos.toByteArray();
            Map map = new HashMap();
            map.put("image", datas);
            invokeListener(V2TXLivePusherObserverType.getByName("onSnapshotComplete"), map);
        }

        /**
         * SDK 内部的 OpenGL 环境的创建通知
         */
        public void onGLContextCreated() {

        }

        /**
         * 自定义视频处理回调
         *
         * @param srcFrame 用于承载未处理的视频画面
         * @param dstFrame 用于承载处理过的视频画面
         */
        public int onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame srcFrame,
                                       V2TXLiveDef.V2TXLiveVideoFrame dstFrame) {
            if (mCustomBeautyProcesser == null) {
                return TXLivePluginDef.ErrorCode.CODE_VALUEISNULL;
            }
            TXCustomBeautyVideoFrame srcThirdFrame = createCustomBeautyVideoFrame(srcFrame);
            TXCustomBeautyVideoFrame dstThirdFrame = createCustomBeautyVideoFrame(dstFrame);
            mCustomBeautyProcesser.onProcessVideoFrame(srcThirdFrame, dstThirdFrame);
            if (dstThirdFrame.texture != null) {
                dstFrame.texture.textureId = dstThirdFrame.texture.textureId;
            }
            dstFrame.data = dstThirdFrame.data;
            dstFrame.buffer = dstThirdFrame.buffer;
            dstFrame.width = dstThirdFrame.width;
            dstFrame.height = dstThirdFrame.height;
            dstFrame.rotation = dstThirdFrame.rotation;
            return 0;
        }

        /**
         * SDK 内部的 OpenGL 环境的销毁通知
         */
        public void onGLContextDestroyed() {
            ITXCustomBeautyProcesserFactory processerFactory = TXLivePluginManager.getBeautyProcesserFactory();
            if (processerFactory != null) {
                processerFactory.destroyCustomBeautyProcesser();
            }
            mCustomBeautyProcesser = null;
        }

        /**
         * @param code 0表示成功，其余值表示失败
         * @param msg  具体错误原因
         */
        public void onSetMixTranscodingConfig(int code, String msg) {
            Log.d(TAG, "onSetMixTranscodingConfig code:" + code + ",msg:" + msg);
            Map map = new HashMap();
            map.put("errCode", code);
            map.put("errMsg", msg);
            invokeListener(V2TXLivePusherObserverType.getByName("onSetMixTranscodingConfig"), map);
        }

        @Override
        public void onScreenCaptureStarted() {
            Log.d(TAG, "onScreenCaptureStarted");
            invokeListener(V2TXLivePusherObserverType.getByName("onScreenCaptureStarted"),
                    Collections.emptyMap());
        }

        @Override
        public void onScreenCaptureStopped(int reason) {
            Log.d(TAG, "onScreenCaptureStopped");
            invokeListener(V2TXLivePusherObserverType.getByName("onScreenCaptureStopped"),
                    Collections.emptyMap());
        }

        public void invokeListener(V2TXLivePusherObserverType type, Map map) {
            Log.d(TAG, "invokeListener type:" + type.getName());
            Map resultParams = new HashMap();
            resultParams.put("type", type.getName());
            if (map != null) {
                resultParams.put("params", map);
            }
            /// 方法名唯一， Type区分使用那个方法
            if (mChannel != null) {
                mChannel.invokeMethod("onPusherListener", resultParams);
            }
        }
    }

    private static V2TXLiveDef.V2TXLiveBufferType convertV2LiveBufferType(TXCustomBeautyBufferType type) {
        switch (type) {
            case TXCustomBeautyBufferTypeUnknown:
                return V2TXLiveBufferTypeUnknown;
            case TXCustomBeautyBufferTypeByteBuffer:
                return V2TXLiveBufferTypeByteBuffer;
            case TXCustomBeautyBufferTypeByteArray:
                return V2TXLiveBufferTypeByteArray;
            case TXCustomBeautyBufferTypeTexture:
                return V2TXLiveBufferTypeTexture;
            default:
                return V2TXLiveBufferTypeUnknown;
        }
    }

    private static final V2TXLiveDef.V2TXLivePixelFormat convertV2LivePixelFormat(TXCustomBeautyPixelFormat format) {
        switch (format) {
            case TXCustomBeautyPixelFormatUnknown:
                return V2TXLivePixelFormatUnknown;
            case TXCustomBeautyPixelFormatI420:
                return V2TXLivePixelFormatI420;
            case TXCustomBeautyPixelFormatTexture2D:
                return V2TXLivePixelFormatTexture2D;
            default:
                return V2TXLivePixelFormatUnknown;
        }
    }


    /**
     * 基于 V2TXLiveVideoFrame 创建
     * @param frame
     */
    private static TXCustomBeautyVideoFrame createCustomBeautyVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame frame) {
        TXCustomBeautyVideoFrame videoFrame = new TXCustomBeautyVideoFrame();
        if (frame.pixelFormat == V2TXLivePixelFormatUnknown) {
            videoFrame.pixelFormat = TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatUnknown;
        } else if (frame.pixelFormat == V2TXLivePixelFormatI420) {
            videoFrame.pixelFormat = TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatI420;
        } else if (frame.pixelFormat == V2TXLivePixelFormatTexture2D) {
            videoFrame.pixelFormat = TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatTexture2D;
        }

        if (frame.bufferType == V2TXLiveBufferTypeUnknown) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeUnknown;
        } else if (frame.bufferType == V2TXLiveBufferTypeByteArray) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeByteArray;
        } else if (frame.bufferType == V2TXLiveBufferTypeByteBuffer) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeByteBuffer;
        } else if (frame.bufferType == V2TXLiveBufferTypeTexture) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeTexture;
        }

        if (null != frame.texture) {
            videoFrame.texture = new TXCustomBeautyDef.TXThirdTexture();
            videoFrame.texture.textureId = frame.texture.textureId;
            videoFrame.texture.eglContext10 = frame.texture.eglContext10;
            videoFrame.texture.eglContext14 = frame.texture.eglContext14;
        }

        videoFrame.data = frame.data;
        videoFrame.buffer = frame.buffer;
        videoFrame.width = frame.width;
        videoFrame.height = frame.height;
        videoFrame.rotation = frame.rotation;
        return videoFrame;
    }

    /** ------------------------------TXBeautyManager------------------------------------**/

    /**
     * 设置美颜（磨皮）算法
     * <p>
     * TRTC 内置多种不同的磨皮算法，您可以选择最适合您产品定位的方案：
     * <p>
     * beautyStyle 美颜风格，TXBeautyStyleSmooth：光滑；TXBeautyStyleNature：自然；TXBeautyStylePitu：优图。
     */
    void setBeautyStyle(MethodCall call, MethodChannel.Result result) {

        int beautyStyle = MethodUtils.getMethodParams(call, result, "beautyStyle");
        mTXBeautyManager.setBeautyStyle(beautyStyle);
        result.success(null);
    }

    /**
     * 设置美颜级别
     * <p>
     * beautyLevel 美颜级别，取值范围0 - 9； 0表示关闭，9表示效果最明显。
     */
    void setBeautyLevel(MethodCall call, MethodChannel.Result result) {
        String beautyLevel = MethodUtils.getMethodParams(call, result, "beautyLevel");
        mTXBeautyManager.setBeautyLevel(Float.parseFloat(beautyLevel));
        result.success(null);
    }

    /**
     * 设置美白级别
     * <p>
     * whitenessLevel 美白级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     */
    void setWhitenessLevel(MethodCall call, MethodChannel.Result result) {
        String whitenessLevel = MethodUtils.getMethodParams(call, result, "whitenessLevel");
        mTXBeautyManager.setWhitenessLevel(Float.parseFloat(whitenessLevel));
        result.success(null);
    }

    /**
     * 开启清晰度增强
     */
    void enableSharpnessEnhancement(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        mTXBeautyManager.enableSharpnessEnhancement(enable);
        result.success(null);
    }

    /**
     * 设置红润级别
     * <p>
     * ruddyLevel 红润级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     */
    void setRuddyLevel(MethodCall call, MethodChannel.Result result) {
        String ruddyLevel = MethodUtils.getMethodParams(call, result, "ruddyLevel");
        mTXBeautyManager.setRuddyLevel(Float.parseFloat(ruddyLevel));
        result.success(null);
    }

    /**
     * 设置色彩滤镜效果
     * <p>
     * 色彩滤镜，是一副包含色彩映射关系的颜色查找表图片，您可以在我们提供的官方 Demo 中找到预先准备好的几张滤镜图片。
     * SDK 会根据该查找表中的映射关系，对摄像头采集出的原始视频画面进行二次处理，以达到预期的滤镜效果。
     * image 包含色彩映射关系的颜色查找表图片，必须是 png 格式。
     */
    void setFilter(MethodCall call, MethodChannel.Result result) {
        String type = MethodUtils.getMethodParams(call, result, "type");
        final String imageUrl = MethodUtils.getMethodParams(call, result, "imageUrl");
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        mTXBeautyManager.setFilter(myBitmap);
                    } catch (IOException e) {
                        TXCLog.e(TAG, "|method=setFilter|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = mFlutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = mContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                mTXBeautyManager.setFilter(myBitmap);

            } catch (Exception e) {
                TXCLog.e(TAG, "|method=setFilter|error=" + e);
            }
        }
        result.success(null);
    }

    /**
     * 设置色彩滤镜的强度
     * <p>
     * 该数值越高，色彩滤镜的作用强度越明显，经过滤镜处理后的视频画面跟原画面的颜色差异越大。
     * 我默认的滤镜浓度是0.5，如果您觉得默认的滤镜效果不明显，可以设置为 0.5 以上的数字，最大值为1。
     * <p>
     * strength 从0到1，数值越大滤镜效果越明显，默认值为0.5。
     */
    void setFilterStrength(MethodCall call, MethodChannel.Result result) {
        String strength = MethodUtils.getMethodParams(call, result, "strength");
        mTXBeautyManager.setFilterStrength(Float.parseFloat(strength));
        result.success(null);
    }

    /**
     * 设置绿幕背景视频，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * 此接口所开启的绿幕功能不具备智能去除背景的能力，需要被拍摄者的背后有一块绿色的幕布来辅助产生特效。
     * <p>
     * path MP4格式的视频文件路径; 设置空值表示关闭特效。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setGreenScreenFile(MethodCall call, MethodChannel.Result result) {
        String path = MethodUtils.getMethodParams(call, result, "path");
        int ret = mTXBeautyManager.setGreenScreenFile(path);
        result.success(ret);
    }

    /**
     * 设置大眼级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * eyeScaleLevel 大眼级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setEyeScaleLevel(MethodCall call, MethodChannel.Result result) {
        int eyeScaleLevel = MethodUtils.getMethodParams(call, result, "eyeScaleLevel");
        int ret = mTXBeautyManager.setEyeScaleLevel(eyeScaleLevel);
        result.success(ret);
    }

    /**
     * 设置瘦脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * faceSlimLevel 瘦脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setFaceSlimLevel(MethodCall call, MethodChannel.Result result) {
        int faceSlimLevel = MethodUtils.getMethodParams(call, result, "faceSlimLevel");
        int ret = mTXBeautyManager.setFaceSlimLevel(faceSlimLevel);
        result.success(ret);
    }

    /**
     * 设置 V 脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * faceVLevel V脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setFaceVLevel(MethodCall call, MethodChannel.Result result) {
        int faceVLevel = MethodUtils.getMethodParams(call, result, "faceVLevel");
        int ret = mTXBeautyManager.setFaceVLevel(faceVLevel);
        result.success(ret);
    }

    /**
     * 设置下巴拉伸或收缩，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * chinLevel 下巴拉伸或收缩级别，取值范围-9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setChinLevel(MethodCall call, MethodChannel.Result result) {
        int chinLevel = MethodUtils.getMethodParams(call, result, "chinLevel");
        int ret = mTXBeautyManager.setChinLevel(chinLevel);
        result.success(ret);
    }

    /**
     * 设置短脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * faceShortLevel 短脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setFaceShortLevel(MethodCall call, MethodChannel.Result result) {
        int faceShortLevel = MethodUtils.getMethodParams(call, result, "faceShortLevel");
        int ret = mTXBeautyManager.setFaceShortLevel(faceShortLevel);
        result.success(ret);
    }

    /**
     * 设置窄脸级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * level 窄脸级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setFaceNarrowLevel(MethodCall call, MethodChannel.Result result) {
        int level = MethodUtils.getMethodParams(call, result, "level");
        int ret = mTXBeautyManager.setFaceNarrowLevel(level);
        result.success(ret);
    }

    /**
     * 设置瘦鼻级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * noseSlimLevel 瘦鼻级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setNoseSlimLevel(MethodCall call, MethodChannel.Result result) {
        int noseSlimLevel = MethodUtils.getMethodParams(call, result, "noseSlimLevel");
        int ret = mTXBeautyManager.setNoseSlimLevel(noseSlimLevel);
        result.success(ret);
    }

    /**
     * 设置亮眼级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * eyeLightenLevel 亮眼级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setEyeLightenLevel(MethodCall call, MethodChannel.Result result) {
        int eyeLightenLevel = MethodUtils.getMethodParams(call, result, "eyeLightenLevel");
        int ret = mTXBeautyManager.setEyeLightenLevel(eyeLightenLevel);
        result.success(ret);
    }

    /**
     * 设置牙齿美白级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * toothWhitenLevel 白牙级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setToothWhitenLevel(MethodCall call, MethodChannel.Result result) {
        int toothWhitenLevel = MethodUtils.getMethodParams(call, result, "toothWhitenLevel");
        int ret = mTXBeautyManager.setToothWhitenLevel(toothWhitenLevel);
        result.success(ret);
    }

    /**
     * 设置祛皱级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * wrinkleRemoveLevel 祛皱级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setWrinkleRemoveLevel(MethodCall call, MethodChannel.Result result) {
        int wrinkleRemoveLevel = MethodUtils.getMethodParams(call, result, "wrinkleRemoveLevel");
        int ret = mTXBeautyManager.setWrinkleRemoveLevel(wrinkleRemoveLevel);
        result.success(ret);
    }

    /**
     * 设置祛眼袋级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * pounchRemoveLevel 祛眼袋级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setPounchRemoveLevel(MethodCall call, MethodChannel.Result result) {
        int pounchRemoveLevel = MethodUtils.getMethodParams(call, result, "pounchRemoveLevel");
        int ret = mTXBeautyManager.setPounchRemoveLevel(pounchRemoveLevel);
        result.success(ret);
    }

    /**
     * 设置法令纹去除级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * smileLinesRemoveLevel 法令纹级别，取值范围0 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setSmileLinesRemoveLevel(MethodCall call, MethodChannel.Result result) {
        int smileLinesRemoveLevel = MethodUtils.getMethodParams(call, result, "smileLinesRemoveLevel");
        int ret = mTXBeautyManager.setSmileLinesRemoveLevel(smileLinesRemoveLevel);
        result.success(ret);
    }

    /**
     * 设置发际线调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * foreheadLevel 发际线级别，取值范围-9 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setForeheadLevel(MethodCall call, MethodChannel.Result result) {
        int foreheadLevel = MethodUtils.getMethodParams(call, result, "foreheadLevel");
        int ret = mTXBeautyManager.setForeheadLevel(foreheadLevel);
        result.success(ret);
    }

    /**
     * 设置眼距，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * eyeDistanceLevel 眼距级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setEyeDistanceLevel(MethodCall call, MethodChannel.Result result) {
        int eyeDistanceLevel = MethodUtils.getMethodParams(call, result, "eyeDistanceLevel");
        int ret = mTXBeautyManager.setEyeDistanceLevel(eyeDistanceLevel);
        result.success(ret);
    }

    /**
     * 设置眼角调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * eyeAngleLevel 眼角调整级别，取值范围-9 - 9；0表示关闭，9表示效果最明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setEyeAngleLevel(MethodCall call, MethodChannel.Result result) {
        int eyeAngleLevel = MethodUtils.getMethodParams(call, result, "eyeAngleLevel");
        int ret = mTXBeautyManager.setEyeAngleLevel(eyeAngleLevel);
        result.success(ret);
    }

    /**
     * 设置嘴型调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * mouthShapeLevel 嘴型级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setMouthShapeLevel(MethodCall call, MethodChannel.Result result) {
        int mouthShapeLevel = MethodUtils.getMethodParams(call, result, "mouthShapeLevel");
        int ret = mTXBeautyManager.setMouthShapeLevel(mouthShapeLevel);
        result.success(ret);
    }

    /**
     * 设置鼻翼调整级别，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * noseWingLevel 鼻翼调整级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setNoseWingLevel(MethodCall call, MethodChannel.Result result) {
        int noseWingLevel = MethodUtils.getMethodParams(call, result, "noseWingLevel");
        int ret = mTXBeautyManager.setNoseWingLevel(noseWingLevel);
        result.success(ret);
    }

    /**
     * 设置鼻子位置，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * nosePositionLevel 鼻子位置级别，取值范围-9 - 9；0表示关闭，小于0表示抬高，大于0表示降低。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setNosePositionLevel(MethodCall call, MethodChannel.Result result) {
        int nosePositionLevel = MethodUtils.getMethodParams(call, result, "nosePositionLevel");
        int ret = mTXBeautyManager.setNosePositionLevel(nosePositionLevel);
        result.success(ret);
    }

    /**
     * 设置嘴唇厚度，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * lipsThicknessLevel 嘴唇厚度级别，取值范围-9 - 9；0表示关闭，小于0表示拉伸，大于0表示收缩。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setLipsThicknessLevel(MethodCall call, MethodChannel.Result result) {
        int lipsThicknessLevel = MethodUtils.getMethodParams(call, result, "lipsThicknessLevel");
        int ret = mTXBeautyManager.setLipsThicknessLevel(lipsThicknessLevel);
        result.success(ret);
    }

    /**
     * 设置脸型，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * faceBeautyLevel 美型级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
     *
     * @return 0：成功；-5：当前 License 对应 feature 不支持。
     */
    void setFaceBeautyLevel(MethodCall call, MethodChannel.Result result) {
        int faceBeautyLevel = MethodUtils.getMethodParams(call, result, "faceBeautyLevel");
        int ret = mTXBeautyManager.setFaceBeautyLevel(faceBeautyLevel);
        result.success(ret);
    }

    /**
     * 选择 AI 动效挂件，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * <p>
     * tmplPath 动效素材文件所在目录
     */
    void setMotionTmpl(MethodCall call, MethodChannel.Result result) {
        String tmplPath = MethodUtils.getMethodParams(call, result, "tmplPath");
        mTXBeautyManager.setMotionTmpl(tmplPath);
        result.success(null);
    }

    /**
     * 是否在动效素材播放时静音，该接口仅在 [企业版 SDK](https://cloud.tencent.com/document/product/647/32689#Enterprise) 中生效
     * 有些挂件本身会有声音特效，通过此 API 可以关闭这些特效播放时所带的声音效果。
     * <p>
     * motionMute true：静音；false：不静音。
     */
    void setMotionMute(MethodCall call, MethodChannel.Result result) {
        boolean motionMute = MethodUtils.getMethodParams(call, result, "motionMute");
        mTXBeautyManager.setMotionMute(motionMute);
        result.success(null);
    }


    /** ------------------------------TXAudioEffectManager------------------------------------**/
    /**
     * 1.1 开启耳返
     * <p>
     * 主播开启耳返后，可以在耳机里听到麦克风采集到的自己发出的声音，该特效适用于主播唱歌的应用场景中。
     * <p>
     * 需要您注意的是，由于蓝牙耳机的硬件延迟非常高，所以在主播佩戴蓝牙耳机时无法开启此特效，请尽量在用户界面上提示主播佩戴有线耳机。
     * 同时也需要注意，并非所有的手机开启此特效后都能达到优秀的耳返效果，我们已经对部分耳返效果不佳的手机屏蔽了该特效。
     *
     * @note 仅在主播佩戴耳机时才能开启此特效，同时请您提示主播佩戴有线耳机。
     * enable true：开启；false：关闭。
     */
    void enableVoiceEarMonitor(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        mTXAudioEffectManager.enableVoiceEarMonitor(enable);
        result.success(null);
    }

    /**
     * 1.2 设置耳返音量
     * <p>
     * 通过该接口您可以设置耳返特效中声音的音量大小。
     * <p>
     * volume 音量大小，取值范围为0 - 100，默认值：100。
     *
     * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
     */
    void setVoiceEarMonitorVolume(MethodCall call, MethodChannel.Result result) {
        int volume = MethodUtils.getMethodParams(call, result, "volume");
        mTXAudioEffectManager.setVoiceEarMonitorVolume(volume);
        result.success(null);
    }

    /**
     * 1.3 设置人声的混响效果
     * <p>
     * 通过该接口您可以设置人声的混响效果，具体特效请参考枚举定义{@link TXAudioEffectManager.TXVoiceReverbType}。
     *
     * @note 设置的效果在退出房间后会自动失效，如果下次进房还需要对应特效，需要调用此接口再次进行设置。
     */
    void setVoiceReverbType(MethodCall call, MethodChannel.Result result) {
        int type = MethodUtils.getMethodParams(call, result, "type");
        mTXAudioEffectManager.setVoiceReverbType(EnumUtils.getTXVoiceReverbType(type));
        result.success(null);
    }

    /**
     * 1.4 设置人声的变声特效
     * <p>
     * 通过该接口您可以设置人声的变声特效，具体特效请参考枚举定义{@link TXAudioEffectManager.TXVoiceChangerType}。
     *
     * @note 设置的效果在退出房间后会自动失效，如果下次进房还需要对应特效，需要调用此接口再次进行设置。
     */
    void setVoiceChangerType(MethodCall call, MethodChannel.Result result) {
        int type = MethodUtils.getMethodParams(call, result, "type");
        mTXAudioEffectManager.setVoiceChangerType(EnumUtils.getTXVoiceChangerType(type));
        result.success(null);
    }

    /**
     * 1.5 设置语音音量
     * <p>
     * 该接口可以设置语音音量的大小，一般配合音乐音量的设置接口 {@link TXAudioEffectManager#setAllMusicVolume} 协同使用，用于调谐语音和音乐在混音前各自的音量占比。
     * <p>
     * volume 音量大小，取值范围为0 - 100，默认值：100。
     *
     * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
     */
    void setVoiceCaptureVolume(MethodCall call, MethodChannel.Result result) {
        int volume = MethodUtils.getMethodParams(call, result, "volume");
        mTXAudioEffectManager.setVoiceCaptureVolume(volume);
        result.success(null);
    }

    /**
     * 1.6 设置语音音调
     * <p>
     * 该接口可以设置语音音调，用于实现变调不变速的目的。
     * <p>
     * pitch 音调，取值范围为-1.0f~1.0f，默认值：0.0f。
     */
    void setVoicePitch(MethodCall call, MethodChannel.Result result) {
        String pitch = MethodUtils.getMethodParams(call, result, "pitch");
        mTXAudioEffectManager.setVoicePitch(Double.parseDouble(pitch));
        result.success(null);
    }

    /// @}
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    背景音乐的相关接口
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 背景音乐的相关接口
    /// @{

    /**
     * 2.0 设置背景音乐的事件回调接口
     * <p>
     * 请在播放背景音乐之前使用该接口设置播放事件回调，以便感知背景音乐的播放进度。
     * <p>
     * musicId   音乐 ID
     */
    void setMusicObserver(MethodCall call, MethodChannel.Result result) {
        int musicId = MethodUtils.getMethodParams(call, result, "musicId");
        mTXAudioEffectManager.setMusicObserver(musicId, new TXAudioEffectManager.TXMusicPlayObserver() {
            @Override
            public void onStart(int i, int i1) {
                //TODO 回调实现
            }

            @Override
            public void onPlayProgress(int i, long l, long l1) {

            }

            @Override
            public void onComplete(int i, int i1) {

            }
        });
        result.success(null);
    }

    /**
     * 2.1 开始播放背景音乐
     * <p>
     * 每个音乐都需要您指定具体的 ID，您可以通过该 ID 对音乐的开始、停止、音量等进行设置。
     *
     * @note 1. 如果要多次播放同一首背景音乐，请不要每次播放都分配一个新的 ID，我们推荐使用相同的 ID。
     * 2. 若您希望同时播放多首不同的音乐，请为不同的音乐分配不同的 ID 进行播放。
     * 3. 如果使用同一个 ID 播放不同音乐，SDK 会先停止播放旧的音乐，再播放新的音乐。
     */
    void startPlayMusic(MethodCall call, MethodChannel.Result result) {
        String musicParam = MethodUtils.getParamCanBeNull(call, result, "musicParam");
        TXAudioEffectManager.AudioMusicParam audioMusicParam =
                new Gson().fromJson(musicParam, TXAudioEffectManager.AudioMusicParam.class);
        mTXAudioEffectManager.setMusicObserver(audioMusicParam.id, new V2TXMusicPlayObserverImpl());
        boolean isSuccess = mTXAudioEffectManager.startPlayMusic(audioMusicParam);
        result.success(isSuccess);
    }

    /**
     * 2.2 停止播放背景音乐
     * <p>
     * id  音乐 ID
     */
    void stopPlayMusic(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        mTXAudioEffectManager.setMusicObserver(id, null);
        mTXAudioEffectManager.stopPlayMusic(id);
        result.success(null);
    }

    /**
     * 2.3 暂停播放背景音乐
     * <p>
     * id  音乐 ID
     */
    void pausePlayMusic(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        mTXAudioEffectManager.pausePlayMusic(id);
        result.success(null);
    }

    /**
     * 2.4 恢复播放背景音乐
     * <p>
     * id  音乐 ID
     */
    void resumePlayMusic(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        mTXAudioEffectManager.resumePlayMusic(id);
        result.success(null);
    }

    /**
     * 2.5 设置所有背景音乐的本地音量和远端音量的大小
     * <p>
     * 该接口可以设置所有背景音乐的本地音量和远端音量。
     * - 本地音量：即主播本地可以听到的背景音乐的音量大小。
     * - 远端音量：即观众端可以听到的背景音乐的音量大小。
     * <p>
     * volume 音量大小，取值范围为0 - 100，默认值：100。
     *
     * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
     */
    void setAllMusicVolume(MethodCall call, MethodChannel.Result result) {
        int volume = MethodUtils.getParamCanBeNull(call, result, "volume");
        mTXAudioEffectManager.setAllMusicVolume(volume);
        result.success(null);
    }

    /**
     * 2.6 设置某一首背景音乐的远端音量的大小
     * <p>
     * 该接口可以细粒度地控制每一首背景音乐的远端音量，也就是观众端可听到的背景音乐的音量大小。
     * <p>
     * id     音乐 ID
     * volume 音量大小，取值范围为0 - 100；默认值：100
     *
     * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
     */
    void setMusicPublishVolume(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        int volume = MethodUtils.getParamCanBeNull(call, result, "volume");
        mTXAudioEffectManager.setMusicPublishVolume(id, volume);
        result.success(null);
    }

    /**
     * 2.7 设置某一首背景音乐的本地音量的大小
     * <p>
     * 该接口可以细粒度地控制每一首背景音乐的本地音量，也就是主播本地可以听到的背景音乐的音量大小。
     * <p>
     * id     音乐 ID
     * volume 音量大小，取值范围为0 - 100，默认值：100。
     *
     * @note 如果将 volume 设置成 100 之后感觉音量还是太小，可以将 volume 最大设置成 150，但超过 100 的 volume 会有爆音的风险，请谨慎操作。
     */
    void setMusicPlayoutVolume(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        int volume = MethodUtils.getParamCanBeNull(call, result, "volume");
        mTXAudioEffectManager.setMusicPlayoutVolume(id, volume);
        result.success(null);
    }

    /**
     * 2.8 调整背景音乐的音调高低
     * <p>
     * id    音乐 ID
     * pitch 音调，默认值是0.0f，范围是：[-1 ~ 1] 之间的浮点数；
     */
    void setMusicPitch(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        String pitch = MethodUtils.getParamCanBeNull(call, result, "pitch");
        mTXAudioEffectManager.setMusicPitch(id, Float.parseFloat(pitch));
        result.success(null);
    }

    /**
     * 2.9 调整背景音乐的变速效果
     * <p>
     * id    音乐 ID
     * speedRate 速度，默认值是1.0f，范围是：[0.5 ~ 2] 之间的浮点数；
     */
    void setMusicSpeedRate(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        String speedRate = MethodUtils.getParamCanBeNull(call, result, "speedRate");
        mTXAudioEffectManager.setMusicSpeedRate(id, Float.parseFloat(speedRate));
        result.success(null);
    }

    /**
     * 2.10 获取背景音乐的播放进度（单位：毫秒）
     * <p>
     * id    音乐 ID
     * 成功返回当前播放时间，单位：毫秒，失败返回-1
     */
    void getMusicCurrentPosInMS(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        long ret = mTXAudioEffectManager.getMusicCurrentPosInMS(id);
        result.success(ret);
    }

    /**
     * 2.11 获取背景音乐的总时长（单位：毫秒）
     * <p>
     * path 音乐文件路径。
     *
     * @return 成功返回时长，失败返回-1
     */
    void getMusicDurationInMS(MethodCall call, MethodChannel.Result result) {
        String path = MethodUtils.getParamCanBeNull(call, result, "path");
        long ret = mTXAudioEffectManager.getMusicDurationInMS(path);
        result.success(ret);
    }

    /**
     * 2.12 设置背景音乐的播放进度（单位：毫秒）
     *
     * @note 请尽量避免过度频繁地调用该接口，因为该接口可能会再次读写音乐文件，耗时稍高。
     * 因此，当用户拖拽音乐的播放进度条时，请在用户完成拖拽操作后再调用本接口。
     * 因为 UI 上的进度条控件往往会以很高的频率反馈用户的拖拽进度，如不做频率限制，会导致较差的用户体验。
     * <p>
     * id  音乐 ID
     * pts 单位: 毫秒
     */
    void seekMusicToPosInMS(MethodCall call, MethodChannel.Result result) {
        int id = MethodUtils.getParamCanBeNull(call, result, "id");
        int pts = MethodUtils.getParamCanBeNull(call, result, "pts");
        mTXAudioEffectManager.seekMusicToPosInMS(id, pts);
        result.success(null);
    }

    /** ------------------------------TXAudioEffectManager------------------------------------**/
    /**
     * 1.1 判断当前是否为前置摄像头（仅适用于移动端）
     */
    void isFrontCamera(MethodCall call, MethodChannel.Result result) {
        result.success(mTXDeviceManager.isFrontCamera());
    }

    /**
     * 1.2 切换前置或后置摄像头（仅适用于移动端）
     */
    void switchCamera(MethodCall call, MethodChannel.Result result) {
        boolean frontCamera = MethodUtils.getMethodParams(call, result, "isFrontCamera");
        int ret = mTXDeviceManager.switchCamera(frontCamera);
        result.success(ret);
    }

    /**
     * 1.3 获取摄像头的最大缩放倍数（仅适用于移动端）
     */
    void getCameraZoomMaxRatio(MethodCall call, MethodChannel.Result result) {
        result.success(mTXDeviceManager.getCameraZoomMaxRatio());
    }

    /**
     * 1.4 设置摄像头的缩放倍数（仅适用于移动端）
     * <p>
     * zoomRatio 取值范围1 - 5，取值为1表示最远视角（正常镜头），取值为5表示最近视角（放大镜头）。
     */
    void setCameraZoomRatio(MethodCall call, MethodChannel.Result result) {
        String zoomRatio = MethodUtils.getMethodParams(call, result, "value");
        int ret = mTXDeviceManager.setCameraZoomRatio(Float.parseFloat(zoomRatio));
        result.success(ret);
    }

    /**
     * 1.5 查询是否支持自动识别人脸位置（仅适用于移动端）
     */
    void isAutoFocusEnabled(MethodCall call, MethodChannel.Result result) {
        result.success(mTXDeviceManager.isAutoFocusEnabled());
    }

    /**
     * 1.6 开启自动对焦功能（仅适用于移动端）
     * <p>
     * 开启后，SDK 会自动检测画面中的人脸位置，并将摄像头的焦点始终对焦在人脸位置上。
     */
    void enableCameraAutoFocus(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        int ret = mTXDeviceManager.enableCameraAutoFocus(enable);
        result.success(ret);
    }

    /**
     * 1.7 设置摄像头的对焦位置（仅适用于移动端）
     * <p>
     * 您可以通过该接口实现如下交互：
     * 1. 在本地摄像头的预览画面上，允许用户单击操作。
     * 2. 在用户的单击位置显示一个矩形方框，以示摄像头会在此处对焦。
     * 3. 随后将用户点击位置的坐标通过本接口传递给 SDK，之后 SDK 会操控摄像头按照用户期望的位置进行对焦。
     *
     * @return 0：操作成功；负数：操作失败。
     * @note 使用该接口的前提是先通过 {@link TXDeviceManager#enableCameraAutoFocus} 关闭自动对焦功能。
     * x,y 对焦位置，请传入期望对焦点的坐标值
     */
    void setCameraFocusPosition(MethodCall call, MethodChannel.Result result) {
        int x = MethodUtils.getMethodParams(call, result, "x");
        int y = MethodUtils.getMethodParams(call, result, "y");
        mTXDeviceManager.setCameraFocusPosition(x, y);
        result.success(null);
    }

    /**
     * 1.8 开启/关闭闪光灯，也就是手电筒模式（仅适用于移动端）
     */
    void enableCameraTorch(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodUtils.getMethodParams(call, result, "enable");
        boolean ret = mTXDeviceManager.enableCameraTorch(enable);
        result.success(ret);
    }

    /**
     * 1.9 设置音频路由（仅适用于移动端）
     * <p>
     * 手机有两个音频播放设备：一个是位于手机顶部的听筒，一个是位于手机底部的立体声扬声器。
     * 设置音频路由为听筒时，声音比较小，只有将耳朵凑近才能听清楚，隐私性较好，适合用于接听电话。
     * 设置音频路由为扬声器时，声音比较大，不用将手机贴脸也能听清，因此可以实现“免提”的功能。
     */
    void setAudioRoute(MethodCall call, MethodChannel.Result result) {
        int route = MethodUtils.getMethodParams(call, result, "route");
        int ret = mTXDeviceManager.setAudioRoute(EnumUtils.getTXAudioRoute(route));
        result.success(ret);
    }

    /**
     * 设置系统音量类型（仅适用于移动端）
     */
    void setSystemVolumeType(MethodCall call, MethodChannel.Result result) {
        int type = MethodUtils.getMethodParams(call, result, "type");
        int ret = mTXDeviceManager.setSystemVolumeType(EnumUtils.getTXSystemVolumeType(type));
        result.success(ret);
    }

    private void setFramework() {
        try {
            JSONObject params = new JSONObject();
            params.put("framework", TC_FRAMEWORK_LIVE);
            params.put("component", TC_COMPONENT_PUSHER);
            mPusher.setProperty("setFramework", params.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
