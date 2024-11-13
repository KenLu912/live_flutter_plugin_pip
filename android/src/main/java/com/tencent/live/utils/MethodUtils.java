package com.tencent.live.utils;

import com.tencent.live2.V2TXLiveDef;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static com.tencent.live.TXLivePluginDef.ErrorCode.CODE_PARAMNOTFOUND;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteArray;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteBuffer;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture;

public class MethodUtils {
    private static final String TAG = "TRTCCloudFlutter";

    /**
     * 通用方法，获得参数值，如未找到参数，则直接中断
     */
    public static <T> T getMethodParams(MethodCall methodCall, MethodChannel.Result result, String param) {
        T parameter = methodCall.argument(param);
        if (parameter == null) {
            result.error("Missing parameter",
                    "Cannot find parameter `" + param + "` or `" + param + "` is null!",
                    CODE_PARAMNOTFOUND);
            Logger.error(TAG, "|method=" + methodCall.method + "|arguments=null");
        }
        return parameter;
    }

    /**
     * 通用方法，获得参数值，参数可以为null
     */
    public static <T> T getParamCanBeNull(MethodCall methodCall, MethodChannel.Result result, String param) {
        T parameter = methodCall.argument(param);
        return parameter;
    }

    public static Map handleVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame videoFrame) {
        Map videoFrameParams = new HashMap();
        videoFrameParams.put("pixelFormat", videoFrame.pixelFormat.ordinal());
        videoFrameParams.put("bufferType", videoFrame.bufferType.ordinal());
        videoFrameParams.put("width", videoFrame.width);
        videoFrameParams.put("pixelFormat", videoFrame.height);
        videoFrameParams.put("rotation", videoFrame.rotation);

        if (videoFrame.bufferType == V2TXLiveBufferTypeByteArray) {
            videoFrameParams.put("data", videoFrame.data);
        } else if (videoFrame.bufferType == V2TXLiveBufferTypeTexture) {
            videoFrameParams.put("textureId", videoFrame.texture.textureId);
        } else if (videoFrame.bufferType == V2TXLiveBufferTypeByteBuffer) {
            // TODO: - CVPixelBufferRef 复杂对象
        }
        return videoFrameParams;
    }
}
