package com.tencent.live;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.live.plugin.V2TXLivePlayerPlugin;
import com.tencent.live.plugin.V2TXLivePremierPlugin;
import com.tencent.live.plugin.V2TXLivePusherPlugin;
import com.tencent.live.utils.Logger;
import com.tencent.live.utils.MethodUtils;
import com.tencent.live.view.V2LiveRenderViewFactory;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

// Native管理pusher和player的单例类
public class TXLivePluginManager implements MethodChannel.MethodCallHandler {
    private static final String TAG          = "TXLivePluginManager";
    private static final String CHANNEL_NAME = "live_cloud_manager_channel";

    // 第三方美颜 实例管理对象
    private static ITXCustomBeautyProcesserFactory sProcesserFactory;

    // Pusher 实例管理对象
    private Map<String, V2TXLivePusherPlugin> mPusherMap = new HashMap<>();
    // Player 实例管理对象
    private Map<String, V2TXLivePlayerPlugin> mPlayerMap = new HashMap<>();
    private MethodChannel                     mChannel;
    private BinaryMessenger                   mMessager;
    private Context                           mContext;
    private FlutterPlugin.FlutterAssets       mFlutterAssets;
    private V2LiveRenderViewFactory           mViewFactory;
    private V2TXLivePremierPlugin             mTXLivePremierPlugin;

    public TXLivePluginManager(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
        mChannel.setMethodCallHandler(this);
        mMessager = flutterPluginBinding.getBinaryMessenger();
        mContext = flutterPluginBinding.getApplicationContext();
        mFlutterAssets = flutterPluginBinding.getFlutterAssets();
        mViewFactory = new V2LiveRenderViewFactory(mContext, mMessager);
        mTXLivePremierPlugin = new V2TXLivePremierPlugin(mMessager, mContext);
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(V2LiveRenderViewFactory.SIGN, mViewFactory);
    }

    //通过Dart传入的ID创建对应的V2TXLivePusherPlugin实例
    private V2TXLivePusherPlugin createV2TXLivePusherPlugin(String id, int mode) {
        Logger.info(TAG, "createV2TXLivePusherPlugin -> id:" + id);
        V2TXLivePusherPlugin pusher = mPusherMap.get(id);
        if (pusher == null) {
            pusher = new V2TXLivePusherPlugin(id, mode, mMessager, mContext, mFlutterAssets, mViewFactory);
            mPusherMap.put(id, pusher);
        } else {
            Logger.error(TAG, "createV2TXLivePusherPlugin -> id:" + id);
        }
        return pusher;
    }


    private V2TXLivePlayerPlugin createV2TXLivePlayerPlugin(String id) {
        V2TXLivePlayerPlugin player = mPlayerMap.get(id);
        if (player == null) {
            player = new V2TXLivePlayerPlugin(id, mMessager, mContext, mViewFactory);
            mPlayerMap.put(id, player);
        } else {
            Logger.error(TAG, "The Player has been created before， id:" + id);
        }
        return player;
    }

    private void destroyNativePusher(String id) {
        V2TXLivePusherPlugin pusher = mPusherMap.get(id);
        if (pusher != null) {
            pusher.destroy();
            mPusherMap.remove(id);
        }
    }

    private void destroyNativePlayer(String id) {
        V2TXLivePlayerPlugin player = mPlayerMap.get(id);
        if (player != null) {
            player.destroy();
            mPlayerMap.remove(id);
        }
    }

    private V2LiveRenderViewFactory getV2LiveRenderViewFactory() {
        return mViewFactory;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Logger.info(TAG, "TXLivePluginManager onMethodCall -> method:" + call.method
                + ", arguments:" + call.arguments);
        String id = MethodUtils.getMethodParams(call, result, TXLivePluginDef.ParamKey.CALL_MANAGER_ID_KEY);
        if (TextUtils.isEmpty(id)) {
            Logger.error(TAG, "Can not find param by key: "
                    + TXLivePluginDef.ParamKey.CALL_MANAGER_ID_KEY);
            result.error("-1001", "Error", "Can not find param by key: "
                    + TXLivePluginDef.ParamKey.CALL_MANAGER_ID_KEY);
            return;
        }
        boolean isSuccess = true;
        switch (call.method) {
            case MethodName.CREATE_NATIVE_PUSHER:
                int mode = MethodUtils.getMethodParams(call, result, "mode");
                createV2TXLivePusherPlugin(id, mode);
                break;
            case MethodName.CREATE_NATIVE_PLAYER:
                createV2TXLivePlayerPlugin(id);
                break;
            case MethodName.DESTROY_NATIVE_PUSHER:
                destroyNativePusher(id);
                break;
            case MethodName.DESTROY_NATIVE_PLAYER:
                destroyNativePlayer(id);
                break;
            default:
                Logger.error(TAG, "Method:" + call.method + "is not defined");
                result.notImplemented();
                isSuccess = false;
                break;
        }
        if (isSuccess) {
            result.success(0);
        }
    }

    public void destroy() {
        mChannel.setMethodCallHandler(null);
    }

    public interface MethodName {
        String CREATE_NATIVE_PUSHER  = "createNativePusher";
        String CREATE_NATIVE_PLAYER  = "createNativePlayer";
        String DESTROY_NATIVE_PUSHER = "destroyNativePusher";
        String DESTROY_NATIVE_PLAYER = "destroyNativePlayer";
    }

    public static void register(ITXCustomBeautyProcesserFactory processerFactory) {
        sProcesserFactory = processerFactory;
    }

    public static ITXCustomBeautyProcesserFactory getBeautyProcesserFactory() {
        return sProcesserFactory;
    }
}
