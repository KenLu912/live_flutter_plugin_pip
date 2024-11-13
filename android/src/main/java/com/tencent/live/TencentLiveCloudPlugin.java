package com.tencent.live;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * TencentLiveCloudPlugin
 */
public class TencentLiveCloudPlugin implements FlutterPlugin {

    private TXLivePluginManager mTXLiveManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        mTXLiveManager = new TXLivePluginManager(flutterPluginBinding);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mTXLiveManager.destroy();
    }
}
