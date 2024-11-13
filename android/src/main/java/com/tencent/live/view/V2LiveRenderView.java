package com.tencent.live.view;

import android.content.Context;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;

import com.tencent.live.utils.Logger;
import com.tencent.rtmp.ui.TXCloudVideoView;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class V2LiveRenderView implements PlatformView, MethodChannel.MethodCallHandler {
    private static final String TAG = "V2LiveRenderView";

    private TXCloudVideoView    mRemoteView;
    private BinaryMessenger     mMessenger;
    private MethodChannel       mChannel;
    private Context             mContext;
    private int                 mViewId;
    private DestroyViewListener mListener;

    public V2LiveRenderView(int viewId, Context context, BinaryMessenger messenger, DestroyViewListener listener) {
        Logger.info(TAG, "V2LiveRenderView create viewId:" + viewId);
        mContext = context;
        mMessenger = messenger;
        mViewId = viewId;
        mRemoteView = new TXCloudVideoView(context);
        mRemoteView.addVideoView(new TextureView(context));
        mChannel = new MethodChannel(mMessenger, "tx_Live_video_view_" + mViewId);
        mChannel.setMethodCallHandler(this);
        mListener = listener;
    }

    @Override
    public View getView() {
        return mRemoteView;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Logger.info(TAG, "V2LiveRenderView( " + mViewId + ")onMethodCall -> method:"
                + call.method + ", arguments:" + call.arguments);
        String method = call.method;
        switch (method) {
            case "destroyRenderView":
                destroyRenderView();
                break;
            default:
                break;
        }
    }

    private void destroyRenderView() {
        Logger.info(TAG, "V2LiveRenderView destroy viewId:" + mViewId);
        if (mListener != null) {
            mListener.onDestroy(mViewId);
        }
    }
}
