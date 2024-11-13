package com.tencent.live.utils;

import com.tencent.liteav.basic.log.TXCLog;

public class Logger {

    public static final void error(String tag, String msg) {
        TXCLog.e(tag, msg);
    }

    public static final void info(String tag, String msg) {
        TXCLog.i(tag, msg);
    }
}
