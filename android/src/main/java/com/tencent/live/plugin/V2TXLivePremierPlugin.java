package com.tencent.live.plugin;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.live.TXLivePluginDef;
import com.tencent.live.utils.Logger;
import com.tencent.live.utils.MethodUtils;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePremier;

import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class V2TXLivePremierPlugin implements MethodChannel.MethodCallHandler {
    private static final String TAG = "V2TXLivePremierPlugin";

    private MethodChannel   mChannel;
    private BinaryMessenger mMessenger;
    private Context         mContext;
    private Handler         mHandler;

    public V2TXLivePremierPlugin(BinaryMessenger messenger, Context context) {
        mMessenger = messenger;
        mContext = context;
        mChannel = new MethodChannel(mMessenger, "live_cloud_premier");
        mChannel.setMethodCallHandler(this);
        mHandler = new UIHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Logger.info(TAG, "onMethodCall -> method:" + call.method + ", arguments:" + call.arguments);
        try {
            Method method = V2TXLivePremierPlugin.class.getDeclaredMethod(call.method,
                    MethodCall.class, MethodChannel.Result.class);
            method.invoke(this, call, result);
        } catch (Exception e) {
            Logger.error(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        }
    }

    /**
     * 获取 SDK 版本号
     */
    public void getSDKVersionStr(MethodCall call, MethodChannel.Result result) {
        String ret = V2TXLivePremier.getSDKVersionStr();
        result.success(ret);
    }

    /**
     * 设置 SDK 的授权 License
     * 文档地址：https://cloud.tencent.com/document/product/454/34750
     * url licence的地址
     * key licence的秘钥
     */
    public void setLicence(MethodCall call, MethodChannel.Result result) {
        String url = MethodUtils.getMethodParams(call, result, "url");
        String key = MethodUtils.getMethodParams(call, result, "key");
        V2TXLivePremier.setLicence(mContext, url, key);
        V2TXLivePremier.setObserver(new V2TXLivePremierObserverImpl());
        Log.d(TAG, "setLicence url:" + url + ", key:" + key);
        result.success(0);
    }

    /**
     * 设置 Log 的配置信息
     */
    public void setLogConfig(MethodCall call, MethodChannel.Result result) {
        V2TXLiveDef.V2TXLiveLogConfig config = new V2TXLiveDef.V2TXLiveLogConfig();
        Map map = MethodUtils.getMethodParams(call, result, "config");
        if (map != null && map.containsKey("logLevel")) {
            config.logLevel = (int) map.get("logLevel");
        }
        if (map != null && map.containsKey("enableObserver")) {
            config.enableObserver = (boolean) map.get("enableObserver");
        }
        if (map != null && map.containsKey("enableConsole")) {
            config.enableConsole = (boolean) map.get("enableConsole");
        }
        if (map != null && map.containsKey("enableLogFile")) {
            config.enableLogFile = (boolean) map.get("enableLogFile");
        }
        if (map != null && map.containsKey("logPath")) {
            config.logPath = (String) map.get("logPath");
        }
        V2TXLivePremier.setLogConfig(config);
        result.success(0);
    }


    /**
     * 设置 SDK 接入环境
     *
     * @note 如您的应用无特殊需求，请不要调用此接口进行设置。
     * env 目前支持 “default” 和 “GDPR” 两个参数
     * 默认环境，SDK 会在全球寻找最佳接入点进行接入。
     * 所有音视频数据和质量统计数据都不会经过中国大陆地区的服务器。
     */
    public void setEnvironment(MethodCall call, MethodChannel.Result result) {
        String env = MethodUtils.getMethodParams(call, result, "env");
        Log.d(TAG, "setEnvironment env:" + env);
        V2TXLivePremier.setEnvironment(env);
        result.success(0);
    }

    /**
     * 设置 SDK sock5 代理配置
     * <p>
     * host     sock5 代理服务器的地址
     * port     sock5 代理服务器的端口
     * username sock5 代理服务器的验证的用户名
     * password sock5 代理服务器的验证的密码
     * config   sock5 代理服务器的协议配置
     */
    public static void setSocks5Proxy(MethodCall call, MethodChannel.Result result) {
        final String host = MethodUtils.getMethodParams(call, result, "host");
        final int port = MethodUtils.getMethodParams(call, result, "port");
        final String username = MethodUtils.getMethodParams(call, result, "username");
        final String password = MethodUtils.getMethodParams(call, result, "password");
        final Map map = MethodUtils.getMethodParams(call, result, "config");
        final V2TXLiveDef.V2TXLiveSocks5ProxyConfig config = new V2TXLiveDef.V2TXLiveSocks5ProxyConfig();
        if (map != null && map.containsKey("supportHttps")) {
            config.supportHttps = (boolean) map.get("supportHttps");
        }
        if (map != null && map.containsKey("supportTcp")) {
            config.supportTcp = (boolean) map.get("supportTcp");
        }
        if (map != null && map.containsKey("supportUdp")) {
            config.supportUdp = (boolean) map.get("supportUdp");
        }
        Log.d(TAG, "setSocks5Proxy host:" + host + ",port:" + port + ",username:" + username + ",password:" + password);
        V2TXLivePremier.setSocks5Proxy(host, port, username, password, config);
        result.success(0);
    }

    public static void setUserId(MethodCall call, MethodChannel.Result result) {
        final String userId = MethodUtils.getMethodParams(call, result, "userId");
        V2TXLivePremier.setUserId(userId);
        result.success(0);
    }

    class V2TXLivePremierObserverImpl extends V2TXLivePremier.V2TXLivePremierObserver {

        @Override
        public void onLog(int level, String log) {
            Map map = new HashMap();
            map.put("level", level);
            map.put("log", log);
            invokeListener(TXLivePluginDef.V2TXLivePremierObserverType.getByName("onLog"), map);
        }

        @Override
        public void onLicenceLoaded(int result, String reason) {
            Logger.info(TAG, "onLicenceLoaded result:" + result + ",reason:" + reason);
            Map map = new HashMap();
            map.put("result", result);
            map.put("reason", reason);
            invokeListener(TXLivePluginDef.V2TXLivePremierObserverType.getByName("onLicenceLoaded"), map);
        }

        public void invokeListener(TXLivePluginDef.V2TXLivePremierObserverType type, Map map) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    Map resultParams = new HashMap();
                    resultParams.put("type", type.getName());
                    if (map != null) {
                        resultParams.put("params", map);
                    }
                    if (mChannel != null) {
                        mChannel.invokeMethod("onPremierListener", resultParams);
                    }
                }
            });
        }
    }

    static class UIHandler extends Handler {
        WeakReference<V2TXLivePremierPlugin> pluginReference;

        public UIHandler(V2TXLivePremierPlugin plugin) {
            pluginReference = new WeakReference<>(plugin);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {

        }
    }
}
