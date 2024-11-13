package com.tencent.live.view;

import android.content.Context;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * 视频视图工厂类，否则创建视图
 */
public class V2LiveRenderViewFactory extends PlatformViewFactory implements DestroyViewListener {
    private static final String TAG  = "TRTCCloudFlutter";
    public static final  String SIGN = "v2_live_view_factory";

    private BinaryMessenger                mMessenger;
    private Context                        mContext;
    private Map<Integer, V2LiveRenderView> mViewMap = new HashMap<>();

    public V2LiveRenderViewFactory(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        mContext = context;
        this.mMessenger = messenger;
    }

    public V2LiveRenderViewFactory(MessageCodec<Object> createArgsCodec) {
        super(createArgsCodec);
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        V2LiveRenderView view = mViewMap.get(viewId);
        if (view == null) {
            view = new V2LiveRenderView(viewId, context, mMessenger, this);
            mViewMap.put(viewId, view);
        }
        return view;
    }

    public V2LiveRenderView getViewById(int viewId) {
        return mViewMap.get(viewId);
    }

    @Override
    public void onDestroy(int viewId) {
        if (mViewMap.containsKey(viewId)) {
            mViewMap.remove(viewId);
        }
    }
}
