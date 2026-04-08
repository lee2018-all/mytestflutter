package com.plugs.core.util;

import android.annotation.SuppressLint;
import android.content.Context;

public final class Utils {

    @SuppressLint("StaticFieldLeak")
    private static Context sContext;
    public static void saveContext(Context context){
        sContext = context;
    }

    public static Context getApp() {
        return sContext;
    }

}
