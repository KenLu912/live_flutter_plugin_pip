package com.tencent.live.utils;

import android.os.Bundle;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class AndroidUtils {
    public static Map getMapByBundle(Bundle bundle) {
        Map map = new HashMap();
        if (bundle != null) {
            Set<String> keySet = bundle.keySet();
            for (String key : keySet) {
                map.put(key, bundle.get(key));
            }
        }
        return map;
    }
}
