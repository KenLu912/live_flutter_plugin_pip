package com.tencent.live.utils;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.live2.V2TXLiveDef;

import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_10;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_5;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_6;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_7;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_8;
import static com.tencent.liteav.audio.TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_9;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveAudioQuality.V2TXLiveAudioQualityDefault;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveAudioQuality.V2TXLiveAudioQualityMusic;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveAudioQuality.V2TXLiveAudioQualitySpeech;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteArray;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteBuffer;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeUnknown;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFill;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFit;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeAuto;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeDisable;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeEnable;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatI420;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatTexture2D;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatUnknown;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation180;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation270;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation90;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1280x720;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution160x160;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1920x1080;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution270x270;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution320x180;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution320x240;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution480x270;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution480x360;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution480x480;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x480;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModeLandscape;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;

public class EnumUtils {

    public static V2TXLiveDef.V2TXLiveVideoResolutionMode getV2TXLiveVideoResolutionMode(int index) {
        switch (index) {
            case 0:
                return V2TXLiveVideoResolutionModeLandscape;
            case 1:
                return V2TXLiveVideoResolutionModePortrait;
            default:
                break;
        }
        return V2TXLiveVideoResolutionModeLandscape;
    }

    public static V2TXLiveDef.V2TXLiveVideoResolution getV2TXLiveVideoResolution(int index) {
        switch (index) {
            case 0:
                return V2TXLiveVideoResolution160x160;
            case 1:
                return V2TXLiveVideoResolution270x270;
            case 2:
                return V2TXLiveVideoResolution480x480;
            case 3:
                return V2TXLiveVideoResolution320x240;
            case 4:
                return V2TXLiveVideoResolution480x360;
            case 5:
                return V2TXLiveVideoResolution640x480;
            case 6:
                return V2TXLiveVideoResolution320x180;
            case 7:
                return V2TXLiveVideoResolution480x270;
            case 8:
                return V2TXLiveVideoResolution640x360;
            case 9:
                return V2TXLiveVideoResolution960x540;
            case 10:
                return V2TXLiveVideoResolution1280x720;
            case 11:
                return V2TXLiveVideoResolution1920x1080;
            default:
                break;
        }
        return V2TXLiveVideoResolution960x540;
    }

    public static V2TXLiveDef.V2TXLiveMirrorType getV2TXLiveMirrorType(int index) {
        switch (index) {
            case 0:
                return V2TXLiveMirrorTypeAuto;
            case 1:
                return V2TXLiveMirrorTypeEnable;
            case 2:
                return V2TXLiveMirrorTypeDisable;
            default:
                break;
        }
        return V2TXLiveMirrorTypeAuto;
    }

    public static V2TXLiveDef.V2TXLiveRotation getV2TXLiveRotation(int index) {
        switch (index) {
            case 0:
                return V2TXLiveRotation0;
            case 1:
                return V2TXLiveRotation90;
            case 2:
                return V2TXLiveRotation180;
            case 3:
                return V2TXLiveRotation270;
            default:
                break;
        }
        return V2TXLiveRotation0;
    }

    public static V2TXLiveDef.V2TXLivePixelFormat getV2TXLivePixelFormat(int index) {
        switch (index) {
            case 0:
                return V2TXLivePixelFormatUnknown;
            case 1:
                return V2TXLivePixelFormatI420;
            case 2:
                return V2TXLivePixelFormatTexture2D;
            default:
                break;
        }
        return V2TXLivePixelFormatUnknown;
    }

    public static V2TXLiveDef.V2TXLiveBufferType getV2TXLiveBufferType(int index) {
        switch (index) {
            case 0:
                return V2TXLiveBufferTypeUnknown;
            case 1:
                return V2TXLiveBufferTypeByteBuffer;
            case 2:
                return V2TXLiveBufferTypeByteArray;
            case 3:
                return V2TXLiveBufferTypeTexture;
            default:
                break;
        }
        return V2TXLiveBufferTypeUnknown;
    }

    public static V2TXLiveDef.V2TXLiveFillMode getV2TXLiveFillMode(int index) {
        switch (index) {
            case 0:
                return V2TXLiveFillModeFill;
            case 1:
                return V2TXLiveFillModeFit;
            default:
                break;
        }
        return V2TXLiveFillModeFill;
    }

    public static V2TXLiveDef.V2TXLiveAudioQuality getV2TXLiveAudioQuality(int index) {
        switch (index) {
            case 0:
                return V2TXLiveAudioQualitySpeech;
            case 1:
                return V2TXLiveAudioQualityDefault;
            case 2:
                return V2TXLiveAudioQualityMusic;
            default:
                break;
        }
        return V2TXLiveAudioQualityDefault;
    }

    public static TXAudioEffectManager.TXVoiceReverbType getTXVoiceReverbType(int index) {
        switch (index) {
            case 0:
                return TXLiveVoiceReverbType_0;
            case 1:
                return TXLiveVoiceReverbType_1;
            case 2:
                return TXLiveVoiceReverbType_2;
            case 3:
                return TXLiveVoiceReverbType_3;
            case 4:
                return TXLiveVoiceReverbType_4;
            case 5:
                return TXLiveVoiceReverbType_5;
            case 6:
                return TXLiveVoiceReverbType_6;
            case 7:
                return TXLiveVoiceReverbType_7;
            case 8:
                return TXLiveVoiceReverbType_8;
            case 9:
                return TXLiveVoiceReverbType_9;
            case 10:
                return TXLiveVoiceReverbType_10;
            default:
                break;
        }
        return TXLiveVoiceReverbType_0;
    }

    public static TXAudioEffectManager.TXVoiceChangerType getTXVoiceChangerType(int index) {
        switch (index) {
            case 0:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
            case 1:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
            case 2:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
            case 3:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
            case 4:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
            case 5:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_5;
            case 6:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_6;
            case 7:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_7;
            case 8:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_8;
            case 9:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_9;
            case 10:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_10;
            case 11:
                return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_11;
            default:
                break;
        }
        return TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
    }

    public static TXDeviceManager.TXAudioRoute getTXAudioRoute(int index) {
        switch (index) {
            case 0:
                return TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone;
            case 1:
                return TXDeviceManager.TXAudioRoute.TXAudioRouteEarpiece;
            default:
                break;
        }
        return TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone;
    }

    public static TXDeviceManager.TXSystemVolumeType getTXSystemVolumeType(int index) {
        switch (index) {
            case 0:
                return TXDeviceManager.TXSystemVolumeType.TXSystemVolumeTypeAuto;
            case 1:
                return TXDeviceManager.TXSystemVolumeType.TXSystemVolumeTypeMedia;
            case 2:
                return TXDeviceManager.TXSystemVolumeType.TXSystemVolumeTypeVOIP;
            default:
                break;
        }
        return TXDeviceManager.TXSystemVolumeType.TXSystemVolumeTypeAuto;
    }

    public static V2TXLiveDef.V2TXLiveMixInputType getV2TXLiveMixInputType(int index) {
        switch (index) {
            case 0:
                return V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypeAudioVideo;
            case 1:
                return V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypePureVideo;
            case 2:
                return V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypePureAudio;
            default:
                break;
        }
        return V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypeAudioVideo;
    }
}
